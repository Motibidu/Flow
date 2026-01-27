package com.flow.coretime.elecApproval.service;

import com.flow.coretime.elecApproval.mapper.ElecApprovalHistoryMapper;
import com.flow.coretime.elecApproval.model.AttachmentEntity;
import com.flow.coretime.elecApproval.model.DocumentRespDto;
import com.flow.coretime.elecApproval.model.ElecApprovalHistoryRespDto;
import com.flow.coretime.global.exception.UnauthorizedException;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Slf4j
@Component("documentChecker")
@RequiredArgsConstructor
public class DocumentChecker {

    private final ElecApprovalQueryService elecApprovalQueryService;
    private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
    private final AttachmentService attachmentService;

    // 현재 사용자가 문서의 기안자인지 확인
    public boolean isInitiator(Integer docId, String username) {

        DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
        String initiatorId = document.getInitiatorId();
        boolean isInitiator = initiatorId.equals(username);
        return isInitiator;
    }

    // 현재 사용자가 문서의 현재 결재자인지 확인
    public boolean isCurrentApprover(Integer docId, String username) {
        ElecApprovalHistoryRespDto currentPendingApproval = elecApprovalHistoryMapper
                .getCurrentApprovalHistory(docId)
                .orElseThrow(() -> new UnauthorizedException(HttpStatus.BAD_REQUEST, "결재 순서가 아니거나 결재 권한이 없습니다."));
        return currentPendingApproval.getApproverId().equals(username);
    }

    // 현재 사용자가 문서를 볼 권한이 있는지 확인 (기안자 또는 결재라인에 포함)
    public boolean isViewer(Integer docId, String username) {
        // 1. 기안자인지 확인
        if (isInitiator(docId, username)) {
            return true;
        }
        // 2. 결재 라인에 포함되어 있는지 확인
        return elecApprovalHistoryMapper.isUserInApprovalLine(docId, username) > 0;
    }

    // 파일 다운로드 권한 확인
    public boolean canDownloadFile(Long fileId, String username) {
        AttachmentEntity attachment = attachmentService.getAttachment(fileId);
        if (attachment == null) {
            return false;
        }
        return isViewer(attachment.getDocId(), username);
    }
}
