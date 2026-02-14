package com.flow.coretime.elecApproval.service;

import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentStatus;
import com.flow.coretime.elecApproval.mapper.ElecApprovalHistoryMapper;
import com.flow.coretime.elecApproval.mapper.ElecApprovalMapper;
import com.flow.coretime.elecApproval.mapper.MyApprovalLineMapper;
import com.flow.coretime.elecApproval.model.*;
import com.flow.coretime.global.event.NotificationEvent;
import com.flow.coretime.global.exception.DocumentConflictException;
import com.flow.coretime.global.exception.UnauthorizedException;
import com.flow.coretime.users.service.SubstituteApprovalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ElecApprovalCommandService {

    private final ElecApprovalMapper elecApprovalMapper;
    private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
    private final MyApprovalLineMapper myApprovalLineMapper;
    private final ApplicationEventPublisher eventPublisher;
    private final AttachmentService attachmentService;
    private final ElecApprovalQueryService elecApprovalQueryService; // To get document for auth check
    private final SubstituteApprovalService substituteApprovalService;

    @Transactional
    public void recallDocument(int docId, String userId) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        if (!document.getInitiatorId().equals(userId)) {
            throw new UnauthorizedException("문서 기안자만 상신을 취소할 수 있습니다.");
        }
        validateDocumentIsPendingOrInProgress(document);

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
        }

        int updatedRows = elecApprovalMapper.recallDocument(document.getDocId(), userId, document.getVersion());

        if (updatedRows == 0) {
            handleOptimisticLockFailure(docId);
        }
    }

    @Transactional
    public void deleteDocument(int docId) {

        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);

        // 문서상태 유효성 검증
        DocumentStatus status = document.getStatus();
        if (status != DocumentStatus.TEMP && status != DocumentStatus.RECALLED) {
            throw new IllegalStateException("임시저장 또는 상신취소 상태인 문서만 삭제가 가능합니다.");
        }

        // 결재선 삭제
        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

        // 첨부파일 삭제
        attachmentService.deleteAttachmentsByDocId(docId);

        // 문서 삭제
        elecApprovalMapper.deleteDocument(docId);
        log.info("문서 및 결재선 삭제 완료 - 문서ID: {}", docId);
    }

    @Transactional
    @CacheEvict(value = "myApprovalLines", allEntries = true)
    public void saveMyApprovalLine(String userId, MyLineSaveDto myLineSaveDto) {
        MyApprovalLineEntity myApprovalLineEntity = MyApprovalLineEntity.builder()
                .userId(userId)
                .title(myLineSaveDto.getTitle())
                .build();
        myApprovalLineMapper.insertMyApprovalLine(myApprovalLineEntity);
        Long generatedLineId = myApprovalLineEntity.getId();

        List<MyApprovalLineDetailEntity> details = new ArrayList<>();
        List<String> approverIds = myLineSaveDto.getApproverIds();
        for (int i = 0; i < approverIds.size(); i++) {
            MyApprovalLineDetailEntity detail = new MyApprovalLineDetailEntity();
            detail.setLineId(generatedLineId);
            detail.setApproverId(approverIds.get(i));
            detail.setSeq(i + 1);
            details.add(detail);
        }

        if (!details.isEmpty()) {
            myApprovalLineMapper.insertMyApprovalLineDetail(details);
        }
    }

    @Transactional
    public void deleteMyApprovalLine(String userId, int lineId) {
        myApprovalLineMapper.deleteMyApprovalLine(userId, lineId);
        myApprovalLineMapper.deleteMyApprovalLineDetail(lineId);
    }

    @Transactional
    public void saveDocumentAndInitialApproval(DocumentReqDto request, List<MultipartFile> files, String loginId) {

        // 문서저장
        DocumentEntity documentEntity = DocumentEntity.builder()
                .docType(request.getDocType())
                .title(request.getTitle())
                .jsonContent(request.getJsonContent())
                .initiatorId(loginId)
                .status(DocumentStatus.PENDING)
                .draftDate(new Date())
                .updatedAt(new Date())
                .build();

        elecApprovalMapper.insertDocumentEntity(documentEntity);
        int docId = documentEntity.getDocId();

        // 결재선 생성
        createApprovalLine(docId, request.getApproverIds());

        // 첫번째 결재자에게 알림 전송
        if (request.getApproverIds() != null && !request.getApproverIds().isEmpty()) {
            String firstApproverId = request.getApproverIds().get(0);
            eventPublisher.publishEvent(new NotificationEvent(this, docId, firstApproverId, documentEntity.getTitle(),
                    "새로운 결재문서가 도착했습니다: " + documentEntity.getDocType().getDisplayName(),
                    "/elecApproval/detail/" + docId));
        }

        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
    }

    @Transactional
    public void saveTempDocument(DocumentReqDto request, List<MultipartFile> files, String loginId) {

        DocumentEntity documentEntity = DocumentEntity.builder()
                .docType(request.getDocType())
                .title(request.getTitle())
                .jsonContent(request.getJsonContent())
                .initiatorId(loginId)
                .status(DocumentStatus.TEMP)
                .draftDate(new Date())
                .updatedAt(new Date())
                .build();
        elecApprovalMapper.insertDocumentEntity(documentEntity);
        int docId = documentEntity.getDocId();

        createApprovalLine(docId, request.getApproverIds());

        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
    }

    @Transactional
    public void updateTempDocument(int docId, DocumentReqDto request, List<MultipartFile> files,
            List<Long> deleteFileIds, String loginId) {
        DocumentRespDto existingDocument = elecApprovalQueryService.getDocumentById(docId);
        if (!existingDocument.getInitiatorId().equals(loginId)) {
            throw new UnauthorizedException("문서 기안자만 수정할 수 있습니다.");
        }
        if (existingDocument.getStatus() != DocumentStatus.TEMP) {
            throw new IllegalStateException("임시 저장 상태의 문서만 수정할 수 있습니다.");
        }

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

        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);
        createApprovalLine(docId, request.getApproverIds());

        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
        attachmentService.deleteAttachmentsAndFiles(deleteFileIds);
    }

    @Transactional
    public void redraftDocument(int docId, DocumentReqDto request, List<MultipartFile> files,
            List<Long> deleteFileIds) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);

        // 문서 유효성 검증
        DocumentStatus status = document.getStatus();
        if (status != DocumentStatus.TEMP && status != DocumentStatus.RECALLED && status != DocumentStatus.REJECTED) {
            throw new IllegalStateException("재상신할 수 없는 문서 상태입니다. (현재 상태: " + status.getDisplayName() + ")");
        }

        // 문서 업데이트
        document.setTitle(request.getTitle());
        document.setJsonContent(request.getJsonContent());
        document.setStatus(DocumentStatus.PENDING);
        elecApprovalMapper.updateDocumentForRedraft(document);

        // 첨부파일 삭제
        if (files != null && !files.isEmpty()) {
            attachmentService.saveAttachments(docId, files);
        }
        attachmentService.deleteAttachmentsAndFiles(deleteFileIds);
        // 결재선 삭제
        elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

        // 새로운 결재선 생성
        createApprovalLine(docId, request.getApproverIds());

        // 첫번째 결재자에게 알림 전송
        String firstApproverId = request.getApproverIds().get(0);
        eventPublisher.publishEvent(new NotificationEvent(this, docId, firstApproverId, document.getTitle(),
                "재상신된 결재문서가 도착했습니다: " + document.getDocType().getDisplayName(),
                "/elecApproval/detail/" + docId));
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

    @Transactional
    public void approveDocument(int docId, String comment) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        validateDocumentIsPendingOrInProgress(document);

        ElecApprovalHistoryRespDto currentApprovalHistory = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 결재 대기 중인 상태가 아닙니다."));

        currentApprovalHistory.setApprovalStatus(ApprovalStatus.APPROVED);
        currentApprovalHistory.setComments(comment);
        currentApprovalHistory.setActionDate(new Date());
        elecApprovalHistoryMapper.updateApprovalHistory(currentApprovalHistory);

        processApprovalContinuation(document, currentApprovalHistory);
    }

    @Transactional
    public void substituteApprove(int docId, String comment, String actingUserId) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        validateDocumentIsPendingOrInProgress(document);

        ElecApprovalHistoryRespDto currentApprovalHistory = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 결재 대기 중인 상태가 아닙니다."));

        String originalApproverId = currentApprovalHistory.getApproverId();

        if (!substituteApprovalService.isSubstitute(actingUserId, originalApproverId)) {
            throw new UnauthorizedException("대리 결재 권한이 없습니다.");
        }

        currentApprovalHistory.setApprovalStatus(ApprovalStatus.APPROVED);
        currentApprovalHistory.setComments(comment);
        currentApprovalHistory.setActionDate(new Date());
        currentApprovalHistory.setActingApproverId(actingUserId);
        elecApprovalHistoryMapper.updateApprovalHistory(currentApprovalHistory);

        processApprovalContinuation(document, currentApprovalHistory);
    }

    private void processApprovalContinuation(DocumentRespDto document,
            ElecApprovalHistoryRespDto currentApprovalHistory) {
        int docId = document.getDocId();
        elecApprovalHistoryMapper.getNextApprovalHistory(document.getDocId(), currentApprovalHistory.getApprovalOrder())
                .ifPresentOrElse(
                        nextApproval -> {
                            nextApproval.setApprovalStatus(ApprovalStatus.PENDING);
                            elecApprovalHistoryMapper.updateApprovalHistory(nextApproval);
                            document.setStatus(DocumentStatus.IN_PROGRESS);
                            eventPublisher.publishEvent(
                                    new NotificationEvent(this, docId, nextApproval.getApproverId(),
                                            document.getTitle(),
                                            "결재 대기: '" + document.getDocType() + "' 문서의 승인 차례입니다.",
                                            "/elecApproval/detail/" + document.getDocId()));
                        },
                        () -> {
                            document.setStatus(DocumentStatus.APPROVED);
                            eventPublisher.publishEvent(
                                    new NotificationEvent(this, docId, document.getInitiatorId(), document.getTitle(),
                                            "결재 완료: '" + document.getDocType().getDisplayName()
                                                    + "' 문서가 최종 승인되었습니다! 🎉",
                                            "/elecApproval/detail/" + document.getDocId()));
                        });

        document.setUpdatedAt(new Date());
        int updatedRows = elecApprovalMapper.updateDocumentStatus(document);
        if (updatedRows == 0) {
            handleOptimisticLockFailure(document.getDocId());
        }
    }

    @Transactional
    public void rejectApproval(int docId, String comment, String userId) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        validateDocumentIsPendingOrInProgress(document);

        ElecApprovalHistoryRespDto currentApprovalHistory = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 결재 대기 중인 상태가 아닙니다."));

        if (!currentApprovalHistory.getApproverId().equals(userId)) {
            throw new UnauthorizedException("결재 순서가 아니거나 결재 권한이 없습니다.");
        }

        currentApprovalHistory.setApprovalStatus(ApprovalStatus.REJECTED);
        currentApprovalHistory.setComments(comment);
        currentApprovalHistory.setActionDate(new Date());

        elecApprovalHistoryMapper.updateApprovalHistory(currentApprovalHistory);

        processRejectionContinuation(document, currentApprovalHistory);
    }

    @Transactional
    public void substituteRejectApproval(int docId, String comment, String actingUserId) {
        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        validateDocumentIsPendingOrInProgress(document);

        ElecApprovalHistoryRespDto currentApprovalHistory = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 결재 대기 중인 상태가 아닙니다."));

        String originalApproverId = currentApprovalHistory.getApproverId();

        if (!substituteApprovalService.isSubstitute(actingUserId, originalApproverId)) {
            throw new UnauthorizedException("대리 결재 권한이 없습니다.");
        }

        currentApprovalHistory.setApprovalStatus(ApprovalStatus.REJECTED);
        currentApprovalHistory.setComments(comment);
        currentApprovalHistory.setActionDate(new Date());
        currentApprovalHistory.setActingApproverId(actingUserId);

        elecApprovalHistoryMapper.updateApprovalHistory(currentApprovalHistory);

        processRejectionContinuation(document, currentApprovalHistory);
    }

    private void processRejectionContinuation(DocumentRespDto document,
            ElecApprovalHistoryRespDto currentApprovalHistory) {
        int docId = document.getDocId();
        document.setStatus(DocumentStatus.REJECTED);
        document.setUpdatedAt(new Date());
        int updatedRows = elecApprovalMapper.updateDocumentStatus(document);
        if (updatedRows == 0) {
            handleOptimisticLockFailure(docId);
        }

        eventPublisher.publishEvent(new NotificationEvent(this, docId, document.getInitiatorId(), document.getTitle(),
                "결재 반려: '" + document.getDocType().getDisplayName() + "' 문서가 반려되었습니다. 사유를 확인해 주세요. ⚠️",
                "/elecApproval/detail/" + document.getDocId()));
    }

    private void validateDocumentIsPendingOrInProgress(DocumentRespDto document) {
        DocumentStatus status = document.getStatus();
        if (status != DocumentStatus.PENDING && status != DocumentStatus.IN_PROGRESS) {
            throw new IllegalStateException(
                    "문서가 이미 처리되었거나 취소되어 작업을 진행할 수 없습니다. (현재 상태: " + status.getDisplayName() + ")");
        }
    }

    private void handleOptimisticLockFailure(int docId) {
        DocumentRespDto currentDocument = elecApprovalQueryService.getDocumentById(docId);
        String message = String.format("작업을 처리하는 동안 문서 상태가 변경되었습니다. 페이지를 새로고침하여 최신 상태를 확인해주세요. (현재 상태: %s)",
                currentDocument.getStatus().getDisplayName());
        throw new DocumentConflictException(message);
    }
}
