package com.flow.coretime.elecApproval.service;

import com.flow.coretime.elecApproval.mapper.ElecApprovalHistoryMapper;
import com.flow.coretime.elecApproval.mapper.ElecApprovalMapper;
import com.flow.coretime.elecApproval.mapper.MyApprovalLineMapper;
import com.flow.coretime.elecApproval.model.AttachmentEntity;
import com.flow.coretime.elecApproval.model.DocumentRespDto;
import com.flow.coretime.elecApproval.model.ElecApprovalHistoryRespDto;
import com.flow.coretime.elecApproval.model.MyLineResponseDto;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.flow.coretime.elecApproval.enums.DocumentStatus;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ElecApprovalQueryService {

    private final ElecApprovalMapper elecApprovalMapper;
    private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
    private final MyApprovalLineMapper myApprovalLineMapper;

    public List<DocumentRespDto> findPendingApprovals(String currentUserId) {
        return elecApprovalMapper.selectDocumentsToApprove(currentUserId);
    }

    public List<DocumentRespDto> findMyInProgressDocs(String currentUserId) {
        return elecApprovalMapper.selectInProgressDocumentsByInitiatorId(currentUserId);
    }

    public List<DocumentRespDto> findRejectedOrRecalledDocs(String currentUserId) {
        return elecApprovalMapper.selectRejectedOrRecalledDocuments(currentUserId);
    }

    public List<DocumentRespDto> findMyApprovedDocs(String currentUserId) {
        return elecApprovalMapper.selectApprovedDocumentsByInitiatorId(currentUserId);
    }

    public DocumentRespDto getDocumentById(int docId) {
        DocumentRespDto documentRespDto = elecApprovalMapper.selectDocumentById(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

        List<AttachmentEntity> attachments = elecApprovalMapper.selectAttachmentsByDocId(docId);
        documentRespDto.setAttachments(attachments);

        List<ElecApprovalHistoryRespDto> histories = elecApprovalHistoryMapper
                .findApprovalHistoryByDocId(docId);
        documentRespDto.setApprovalHistories(histories);

        return documentRespDto;
    }

    public DocumentRespDto getDocumentById(int docId, String username, boolean isAdmin) {
        DocumentRespDto documentRespDto = elecApprovalMapper.selectDocumentById(docId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

        List<AttachmentEntity> attachments = elecApprovalMapper.selectAttachmentsByDocId(docId);
        documentRespDto.setAttachments(attachments);

        return documentRespDto;
    }

    public String getCurrentApproverIdForDocument(int docId) {
        Optional<ElecApprovalHistoryRespDto> currentPendingApproval = elecApprovalHistoryMapper
                .findCurrentPendingApproval(docId);
        return currentPendingApproval.map(ElecApprovalHistoryRespDto::getApproverId).orElse(null);
    }

    public List<ElecApprovalHistoryRespDto> getApprovalHistoriesForDocument(int docId) {
        return elecApprovalHistoryMapper.findApprovalHistoryByDocId(docId);
    }

    public List<MyLineResponseDto> findMyApprovalLines(String userId) {
        return myApprovalLineMapper.findMyApprovalLines(userId);
    }

    public PageInfo<DocumentRespDto> findAllRejectedOrRecalled(String username, int page, int size) {
        PageHelper.startPage(page, size);
        List<DocumentRespDto> list = elecApprovalMapper.selectAllRejectedOrRecalled(username);
        return new PageInfo<>(list);
    }

    public PageInfo<DocumentRespDto> findAllApproved(String username, int page, int size) {
        PageHelper.startPage(page, size);
        List<DocumentRespDto> list = elecApprovalMapper.selectAllApproved(username);
        return new PageInfo<>(list);
    }

    public PageInfo<DocumentRespDto> findAllTemp(String username, int page, int size) {
        PageHelper.startPage(page, size);
        List<DocumentRespDto> list = elecApprovalMapper.selectAllTemp(username);
        return new PageInfo<>(list);
    }

    public PageInfo<DocumentRespDto> findAllMyTurn(String username, int page, int size) {
        PageHelper.startPage(page, size);
        List<DocumentRespDto> list = elecApprovalMapper.selectAllMyTurn(username);
        return new PageInfo<>(list);
    }

    public PageInfo<DocumentRespDto> findAllPendingOrInProgress(String username, int page, int size,
            String searchType, String keyword) {
        PageHelper.startPage(page, size);

        if (searchType != null && !searchType.isEmpty()) {
            List<DocumentStatus> statusList = new ArrayList<>();
            statusList.add(DocumentStatus.PENDING);
            statusList.add(DocumentStatus.IN_PROGRESS);

            List<DocumentRespDto> list = elecApprovalMapper.selectByStatusAndKeyword(username, statusList,
                    searchType, keyword);
            log.info("list: {}", list);
            return new PageInfo<>(list);
        } else {
            List<DocumentRespDto> list = elecApprovalMapper.selectAllPendingOrInProgress(username);
            return new PageInfo<>(list);
        }
    }
}
