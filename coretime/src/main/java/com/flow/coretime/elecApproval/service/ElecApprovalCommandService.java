package com.flow.coretime.elecApproval.service;

import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentStatus;
import com.flow.coretime.elecApproval.mapper.ElecApprovalHistoryMapper;
import com.flow.coretime.elecApproval.mapper.ElecApprovalMapper;
import com.flow.coretime.elecApproval.mapper.MyApprovalLineMapper;
import com.flow.coretime.elecApproval.model.*;
import com.flow.coretime.global.exception.UnauthorizedException;
import com.flow.coretime.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ElecApprovalCommandService {

    private final ElecApprovalMapper elecApprovalMapper;
    private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
    private final MyApprovalLineMapper myApprovalLineMapper;
    private final NotificationService notificationService;
    private final AttachmentService attachmentService;
    private final ElecApprovalQueryService elecApprovalQueryService; // To get document for auth check

    public void recallDocument(int docId, String userId) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        validateDocumentIsPendingOrInProgress(document);

        int updatedRows = elecApprovalMapper.recallDocument(document.getDocId(), userId, document.getVersion());

        if (updatedRows == 0) {
            throw new IllegalStateException("다른 사용자에 의해 문서가 변경되어 작업을 완료할 수 없습니다.");
        }
    }

    public void deleteDocument(int docId) {

        // 1. 문서 정보 조회
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        DocumentStatus status = document.getStatus();

        // 3. 상태 체크: 임시저장(TEMP) 또는 상신취소(RECALLED) 상태일 때만 삭제 허용
        if (status != DocumentStatus.TEMP && status != DocumentStatus.RECALLED) {
            throw new IllegalStateException("임시저장 또는 상신취소 상태인 문서만 삭제가 가능합니다.");
        }

        // 4. 연관 데이터 삭제: 결재 이력(History)을 먼저 삭제해야 외래키 오류가 발생하지 않음
        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

        // 5. 첨부파일 삭제
        attachmentService.deleteAttachmentsByDocId(docId);

        // 6. 문서 삭제
        elecApprovalMapper.deleteDocument(docId);

        log.info("문서 및 결재선 삭제 완료 - 문서ID: {}", docId);
    }

    @CacheEvict(value = "myApprovalLines", allEntries = true)
    public void saveMyApprovalLine(String userId, MyLineSaveDto myLineSaveDto) {

        MyApprovalLineEntity myApprovalLineEntity = MyApprovalLineEntity.builder()
                .userId(userId)
                .title(myLineSaveDto.getTitle())
                .build();

        myApprovalLineMapper.insertMyApprovalLine(myApprovalLineEntity);

        Long generatedLineId = myApprovalLineEntity.getId();

        // 3. 상세 리스트 만들기 (ID 연결)
        List<MyApprovalLineDetailEntity> details = new ArrayList<>();
        List<String> approverIds = myLineSaveDto.getApproverIds();

        for (int i = 0; i < approverIds.size(); i++) {
            MyApprovalLineDetailEntity detail = new MyApprovalLineDetailEntity();
            detail.setLineId(generatedLineId); // ★ 여기서 연결!
            detail.setApproverId(approverIds.get(i));
            detail.setSeq(i + 1);
            details.add(detail);
        }

        // 4. 상세 저장
        if (!details.isEmpty()) {
            myApprovalLineMapper.insertMyApprovalLineDetail(details);
        }
    }

    public void deleteMyApprovalLine(String userId, int lineId) {
        myApprovalLineMapper.deleteMyApprovalLine(userId, lineId);
        myApprovalLineMapper.deleteMyApprovalLineDetail(lineId);
    }

    public void saveDocumentAndInitialApproval(DocumentReqDto request, List<MultipartFile> files,
            String loginId) {
        // 1. 문서 엔티티 생성
        DocumentEntity documentEntity = DocumentEntity.builder()
                .docType(request.getDocType())
                .title(request.getTitle())
                .jsonContent(request.getJsonContent())
                .initiatorId(loginId)
                .status(DocumentStatus.PENDING)
                .draftDate(new Date())
                .updatedAt(new Date())
                .build();

        // 2. 문서 저장
        elecApprovalMapper.insertDocumentEntity(documentEntity);
        int docId = documentEntity.getDocId();

        // 3. 결재선 생성 및 저장
        createApprovalLine(docId, request.getApproverIds());

        // 첫 번째 결재자에게 알림 전송
        if (request.getApproverIds() != null && !request.getApproverIds().isEmpty()) {
            String firstApproverId = request.getApproverIds().get(0);
            notificationService.send(firstApproverId, documentEntity.getTitle(),
                    "새로운 결재문서가 도착했습니다: " + documentEntity.getDocType().getDisplayName(),
                    "/elecApproval/detail/" + docId);
        }

        // 4. 파일 저장
        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
    }

    public void saveTempDocument(DocumentReqDto request, List<MultipartFile> files, String loginId) {
        // 1. 문서 엔티티 생성
        DocumentEntity documentEntity = DocumentEntity.builder()
                .docType(request.getDocType())
                .title(request.getTitle())
                .jsonContent(request.getJsonContent())
                .initiatorId(loginId)
                .status(DocumentStatus.TEMP)
                .draftDate(new Date())
                .updatedAt(new Date())
                .build();

        // 2. 문서 저장
        elecApprovalMapper.insertDocumentEntity(documentEntity);
        int docId = documentEntity.getDocId();

        // 3. 결재선 생성 및 저장
        createApprovalLine(docId, request.getApproverIds());

        // 4. 파일 저장
        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
    }

    public void updateTempDocument(int docId, DocumentReqDto request, List<MultipartFile> files,
            List<Long> deleteFileIds, String loginId) {

        // 문서 가져오기
        DocumentRespDto existingDocument = elecApprovalQueryService.getDocumentById(docId);

        // 상태 체크: 임시저장(TEMP) 상태일 때만 수정 허용
        if (existingDocument.getStatus() != DocumentStatus.TEMP) {
            throw new IllegalStateException("임시 저장 상태의 문서만 수정할 수 있습니다.");
        }

        // 문서 생성 및 업데이트
        DocumentEntity documentEntity = DocumentEntity.builder()
                .docId(docId)
                .docType(request.getDocType())
                .title(request.getTitle())
                .jsonContent(request.getJsonContent())
                .initiatorId(loginId)
                .status(DocumentStatus.TEMP)
                .draftDate(new Date())
                .updatedAt(new Date())
                .build();

        elecApprovalMapper.updateTempDocumentEntity(documentEntity);

        // 기존 결재선 삭제 및 생성
        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);
        createApprovalLine(docId, request.getApproverIds());

        // 파일 저장 및 삭제
        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
        attachmentService.deleteAttachmentsAndFiles(deleteFileIds);
    }

    public void redraftDocument(int docId, DocumentReqDto request, List<MultipartFile> files,
            List<Long> deleteFileIds) {
        // 문서 가져오기
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        DocumentStatus status = document.getStatus();

        // 상태 체크: 임시저장(TEMP), 상신취소(RECALLED), 또는 반려(REJECTED) 상태일 때만 재상신 가능
        if (status != DocumentStatus.TEMP && status != DocumentStatus.RECALLED && status != DocumentStatus.REJECTED) {
            throw new IllegalStateException("재상신할 수 없는 문서 상태입니다. (현재 상태: " + status.getDisplayName() + ")");
        }

        // 문서 정보 업데이트 (제목, 내용, 상태 -> PENDING)
        document.setTitle(request.getTitle());
        document.setJsonContent(request.getJsonContent());
        document.setStatus(DocumentStatus.PENDING);

        elecApprovalMapper.updateDocumentForRedraft(document);

        // 파일 저장 (새로 추가된 파일이 있는 경우)
        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }

        // 첨부파일+ DB 삭제
        attachmentService.deleteAttachmentsAndFiles(deleteFileIds);

        // 기존 결재선 삭제
        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

        // 결재선 생성 및 저장
        createApprovalLine(docId, request.getApproverIds());

        // 6. 첫 번째 결재자에게 알림 전송
        String firstApproverId = request.getApproverIds().get(0);
        notificationService.send(firstApproverId, document.getTitle(),
                "재상신된 결재문서가 도착했습니다: " + document.getDocType().getDisplayName(),
                "/elecApproval/detail/" + docId);
    }

    private void createApprovalLine(int docId, List<String> approverIds) {
        if (approverIds != null && !approverIds.isEmpty()) {
            List<ElecApprovalHistoryEntity> histories = new ArrayList<>();

            for (int i = 0; i < approverIds.size(); i++) {
                histories.add(ElecApprovalHistoryEntity.builder()
                        .docId(docId)
                        .approverId(approverIds.get(i))
                        .approvalStatus(i == 0 ? ApprovalStatus.PENDING : ApprovalStatus.WAIT)
                        .approvalOrder(i + 1)
                        .build());
            }
            elecApprovalHistoryMapper.insertApprovalHistoryEntities(histories);
        }
    }

    // 문서의 결재상태와 결재선에 지정된 각 결재자의 결재상태를 업데이트 합니다.
    @Transactional
    public void approveApproval(int docId, String comment) {

        // 1. 문서 상태 검증(PENDING, IN_PROGRESS 상태의 문서만 처리 가능, 취소상태라면 불가능)
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        log.info("document: {}", document);

        validateDocumentIsPendingOrInProgress(document);

        // 2. 현재 결재자의 결재상태 업데이트
        ElecApprovalHistoryRespDto currentApprovalHistory = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 결재 대기 중인 상태가 아닙니다."));

        currentApprovalHistory.setApprovalStatus(ApprovalStatus.APPROVED);
        currentApprovalHistory.setComments(comment);
        currentApprovalHistory.setActionDate(new Date());
        elecApprovalHistoryMapper.updateApprovalHistory(currentApprovalHistory);

        // 3. 문서 상태 업데이트
        elecApprovalHistoryMapper.getNextApprovalHistory(docId, currentApprovalHistory.getApprovalOrder() + 1)
                .ifPresentOrElse(
                        nextApproval -> {
                            // 3-1. 다음 결재자가 있는 경우
                            nextApproval.setApprovalStatus(ApprovalStatus.PENDING);
                            elecApprovalHistoryMapper.updateApprovalHistory(nextApproval);
                            document.setStatus(DocumentStatus.IN_PROGRESS);

                            // 4. 다음 결재자에게 결재 대기 알림 전송
                            notificationService.send(nextApproval.getApproverId(), document.getTitle(),
                                    "결재 대기: '" + document.getDocType() + "' 문서의 승인 차례입니다.",
                                    "/elecApproval/detail/" + document.getDocId());
                        },
                        () -> {
                            // 3-2. 다음 결재자가 없는 경우 (최종 승인)
                            document.setStatus(DocumentStatus.APPROVED);

                            // 4. 기안자에게 최종승인 알림 전송
                            notificationService.send(document.getInitiatorId(), document.getTitle(),
                                    "결재 완료: '" + document.getDocType().getDisplayName() + "' 문서가 최종 승인되었습니다! 🎉",
                                    "/elecApproval/detail/" + document.getDocId());
                        });

        document.setUpdatedAt(new Date());
        int updatedRows = elecApprovalMapper.updateDocumentStatus(document);
        if (updatedRows == 0) {
            throw new IllegalStateException("다른 사용자에 의해 문서가 변경되어 작업을 완료할 수 없습니다.");
        }
    }

    @Transactional
    public void rejectApproval(int docId, String comment) {
        // 1. 문서상태 검증
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        validateDocumentIsPendingOrInProgress(document);

        // 2. 현재 결재자의 결재상태 업데이트
        ElecApprovalHistoryRespDto currentApprovalHistory = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 결재 대기 중인 상태가 아닙니다."));

        currentApprovalHistory.setApprovalStatus(ApprovalStatus.REJECTED);
        currentApprovalHistory.setComments(comment);
        currentApprovalHistory.setActionDate(new Date());
        elecApprovalHistoryMapper.updateApprovalHistory(currentApprovalHistory);

        // 3. 문서 상태 업데이트
        document.setStatus(DocumentStatus.REJECTED);
        document.setUpdatedAt(new Date());
        int updatedRows = elecApprovalMapper.updateDocumentStatus(document);
        if (updatedRows == 0) {
            throw new IllegalStateException("다른 사용자에 의해 문서가 변경되어 작업을 완료할 수 없습니다.");
        }

        // 4. 기안자에게 알림 전송
        notificationService.send(document.getInitiatorId(), document.getTitle(),
                "결재 반려: '" + document.getDocType().getDisplayName() + "' 문서가 반려되었습니다. 사유를 확인해 주세요. ⚠️",
                "/elecApproval/detail/" + document.getDocId());
    }

    private void validateDocumentIsPendingOrInProgress(DocumentRespDto document) {
        DocumentStatus status = document.getStatus();
        if (status != DocumentStatus.PENDING && status != DocumentStatus.IN_PROGRESS) {
            throw new IllegalStateException(
                    "문서가 이미 처리되었거나 취소되어 작업을 진행할 수 없습니다. (현재 상태: " + status.getDisplayName() + ")");
        }
    }
}
