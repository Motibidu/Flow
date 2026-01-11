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
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
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

    public void processApproval(int docId, ApprovalStatus approvalStatus, String comment) {

        // 1. 문서 조회
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);

        // 2. 현재 결재자 조회
        ElecApprovalHistoryRespDto currentPendingApproval = elecApprovalHistoryMapper
                .findCurrentPendingApproval(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "현재 결재 대기 중인 상태가 아닙니다."));

        // 3. 결재 또는 반려
        currentPendingApproval.setApprovalStatus(approvalStatus);
        currentPendingApproval.setCommentText(comment);
        currentPendingApproval.setActionDate(new Date()); // 실제 결재 시점 기록
        elecApprovalHistoryMapper.updateApprovalHistory(currentPendingApproval);

        // 4. '결재'인 경우
        if (ApprovalStatus.APPROVED.equals(approvalStatus)) {
            Optional<ElecApprovalHistoryRespDto> nextApprovalHistoryOpt = elecApprovalHistoryMapper
                    .findNextApprover(
                            docId, currentPendingApproval.getApprovalOrder());
            // 4-1. 다음 결재자가 있는 경우: 상태를 PENDING으로 활성화
            if (nextApprovalHistoryOpt.isPresent()) {

                ElecApprovalHistoryRespDto nextApprovalHistory = nextApprovalHistoryOpt.get();
                nextApprovalHistory.setApprovalStatus(ApprovalStatus.PENDING);
                nextApprovalHistory.setCommentText(null);
                nextApprovalHistory.setActionDate(null);
                elecApprovalHistoryMapper.updateApprovalHistory(nextApprovalHistory);

                document.setStatus(DocumentStatus.IN_PROGRESS);

                notificationService.send(nextApprovalHistory.getApproverId(), document.getTitle(),
                        "결재 대기: '" + document.getDocType() + "' 문서의 승인 차례입니다.",
                        "/elecApproval/detail/" + document.getDocId());
                // 4-2. 더 이상 결재자가 없는 경우: 최종 승인 완료
            } else {

                document.setStatus(DocumentStatus.APPROVED);

                notificationService.send(document.getInitiatorId(), document.getTitle(),
                        "결재 완료: '" + document.getDocType() + "' 문서가 최종 승인되었습니다! 🎉",
                        "/elecApproval/detail/" + document.getDocId());
            }
            // 5. 반려인 경우: 문서 상태 변경 및 이후 결재선은 무시됨
        } else if (ApprovalStatus.REJECTED.equals(approvalStatus)) {

            document.setStatus(DocumentStatus.REJECTED);

            notificationService.send(document.getInitiatorId(), document.getTitle(),
                    "결재 반려: '" + document.getDocType() + "' 문서가 반려되었습니다. 사유를 확인해 주세요. ⚠️",
                    "/elecApproval/detail/" + document.getDocId());
        }

        // 5. 문서 최종 상태 반영
        document.setUpdatedAt(new Date());
        elecApprovalMapper.updateDocumentStatus(document);

    }

    public void recallDocument(Long docId, String userId) {
        elecApprovalMapper.recallDocument(docId, userId);
    }

    public void deleteDocument(int docId) {

        // 1. 문서 정보 조회
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);

        // 3. 상태 체크: 상신취소(RECALLED) 상태일 때만 삭제 허용
        if (!DocumentStatus.RECALLED.equals(document.getStatus())) {
            throw new RuntimeException("상신취소 상태인 문서만 삭제가 가능합니다.");
        }

        // 4. 연관 데이터 삭제: 결재 이력(History)을 먼저 삭제해야 외래키 오류가 발생하지 않음
        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

        // 5. 첨부파일 삭제
        attachmentService.deleteAttachmentsByDocId(docId);

        // 6. 문서 삭제
        elecApprovalMapper.deleteDocument(docId);

        log.info("문서 및 결재선 삭제 완료 - 문서ID: {}", docId);
    }

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
}
