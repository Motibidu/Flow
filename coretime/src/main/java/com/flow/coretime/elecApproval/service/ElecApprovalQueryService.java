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
import org.springframework.cache.annotation.Cacheable;
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

    // @Cacheable(value = "myApprovalLines", key = "#p0")
    public List<MyLineResponseDto> findMyApprovalLines(String userId) {
        log.info("Cache Miss - findMyApprovalLines DB 조회: {}", userId);
        return myApprovalLineMapper.findMyApprovalLines(userId);
    }

    public PageInfo<DocumentRespDto> findRejectedOrRecalled(String username, int page, int size, String searchType,
            String keyword) {
        PageHelper.startPage(page, size);

        if (searchType != null && !searchType.isEmpty()) {
            List<DocumentStatus> statusList = new ArrayList<>();
            statusList.add(DocumentStatus.REJECTED);
            statusList.add(DocumentStatus.RECALLED);
            List<DocumentRespDto> list = elecApprovalMapper.selectByStatusAndKeyword(username, statusList, searchType,
                    keyword);
            return new PageInfo<>(list);
        } else {
            List<DocumentRespDto> list = elecApprovalMapper.selectAllRejectedOrRecalled(username);
            return new PageInfo<>(list);
        }
    }

    public PageInfo<DocumentRespDto> findApproved(String username, int page, int size, String searchType,
            String keyword) {
        PageHelper.startPage(page, size);

        if (searchType != null && !searchType.isEmpty()) {
            List<DocumentStatus> statusList = new ArrayList<>();
            statusList.add(DocumentStatus.APPROVED);
            List<DocumentRespDto> list = elecApprovalMapper.selectByStatusAndKeyword(username, statusList, searchType,
                    keyword);
            return new PageInfo<>(list);
        } else {
            List<DocumentRespDto> list = elecApprovalMapper.selectAllApproved(username);
            return new PageInfo<>(list);
        }
    }

    public PageInfo<DocumentRespDto> findAllTemp(String username, int page, int size, String searchType,
            String keyword) {
        PageHelper.startPage(page, size);

        if (searchType != null && !searchType.isEmpty()) {
            List<DocumentStatus> statusList = new ArrayList<>();
            statusList.add(DocumentStatus.TEMP);
            List<DocumentRespDto> list = elecApprovalMapper.selectByStatusAndKeyword(username, statusList, searchType,
                    keyword);
            return new PageInfo<>(list);
        } else {
            List<DocumentRespDto> list = elecApprovalMapper.selectAllTemp(username);
            return new PageInfo<>(list);
        }
    }

    public PageInfo<DocumentRespDto> findMyTurn(String username, int page, int size, String searchType,
            String keyword) {
        PageHelper.startPage(page, size);
        if (searchType != null && !searchType.isEmpty()) {
            List<DocumentRespDto> list = elecApprovalMapper.selectMyTurnByKeyword(username, searchType, keyword);
            return new PageInfo<>(list);
        } else {
            List<DocumentRespDto> list = elecApprovalMapper.selectAllMyTurn(username);
            return new PageInfo<>(list);
        }
    }

    public PageInfo<DocumentRespDto> findPendingOrInProgress(String username, int page, int size,
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
