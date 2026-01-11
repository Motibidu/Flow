package com.flow.coretime.elecApproval.service;

import java.util.ArrayList;
import java.util.Date;
import java.io.File;
import java.io.IOException;
import java.util.UUID;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.multipart.MultipartFile;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.flow.coretime.elecApproval.mapper.ElecApprovalMapper;
import com.flow.coretime.elecApproval.mapper.MyApprovalLineMapper;
import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.PositionType;
import com.flow.coretime.common.enums.RankType;
import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentStatus;
import com.flow.coretime.elecApproval.mapper.ElecApprovalHistoryMapper;
import com.flow.coretime.elecApproval.mapper.ElecApprovalLineConfigMapper;
import com.flow.coretime.elecApproval.model.AttachmentEntity;
import com.flow.coretime.elecApproval.model.DocumentRespDto;
import com.flow.coretime.elecApproval.model.DocumentEntity;
import com.flow.coretime.elecApproval.model.DocumentReqDto;
import com.flow.coretime.elecApproval.model.ElecApprovalHistoryRespDto;
import com.flow.coretime.elecApproval.model.ElecApprovalHistoryEntity;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfigEntity;
import com.flow.coretime.elecApproval.model.MyApprovalLineDetailEntity;
import com.flow.coretime.elecApproval.model.MyApprovalLineEntity;
import com.flow.coretime.elecApproval.model.MyLineResponseDto;
import com.flow.coretime.elecApproval.model.MyLineSaveDto;
import com.flow.coretime.global.exception.UnauthorizedException;
import com.flow.coretime.notification.NotificationService;
import com.flow.coretime.users.mapper.UserMapper;
import com.flow.coretime.users.model.User;
import com.flow.coretime.users.service.UserService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Service
public class ElecApprovalService {

        @Value("${upload.dir}")
        private String uploadDir;

        private final UserService userService;

        private final ElecApprovalMapper elecApprovalMapper;
        private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
        private final ElecApprovalLineConfigMapper elecApprovalLineConfigMapper;
        private final UserMapper userMapper;
        private final NotificationService notificationService;
        private final MyApprovalLineMapper myApprovalLineMapper;

        // 나의 결재 차례인 문서
        public List<DocumentRespDto> getPendingApprovals(String currentUserId) {
                return elecApprovalMapper.selectDocumentsToApprove(currentUserId);
        }

        // 내가 기안한 진행 중 문서
        public List<DocumentRespDto> selectMyInProgressDocs(String currentUserId) {
                return elecApprovalMapper.selectInProgressDocumentsByInitiatorId(currentUserId);
        }

        // 반려 및 취소된 문서
        public List<DocumentRespDto> selectRejectedOrRecalledDocs(String currentUserId) {
                return elecApprovalMapper.selectRejectedOrRecalledDocuments(currentUserId);
        }

        // 최종 승인된 문서
        public List<DocumentRespDto> selectMyApprovedDocs(String currentUserId) {
                return elecApprovalMapper.selectApprovedDocumentsByInitiatorId(currentUserId);
        }

        public void createDocument(DocumentRespDto document) {
                elecApprovalMapper.insertDocument(document);
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

        // 문서의 현재 PENDING 상태 결재자 ID 조회
        public String getCurrentApproverIdForDocument(int docId) {
                Optional<ElecApprovalHistoryRespDto> currentPendingApproval = elecApprovalHistoryMapper
                                .findCurrentPendingApproval(docId);
                return currentPendingApproval.map(ElecApprovalHistoryRespDto::getApproverId).orElse(null);
        }

        // 문서의 모든 결재 이력 조회 (JSP에서 결재선 동적 표시용)
        public List<ElecApprovalHistoryRespDto> getApprovalHistoriesForDocument(int docId) {
                return elecApprovalHistoryMapper.findApprovalHistoryByDocId(docId);
        }

        // 결재하기
        @Transactional
        public void processApproval(int docId, String approverId, ApprovalStatus approvalStatus, String comment) {

                // 1. 문서 조회
                DocumentRespDto document = elecApprovalMapper.selectDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

                // 2. 현재 결재자 조회
                ElecApprovalHistoryRespDto currentPendingApproval = elecApprovalHistoryMapper
                                .findCurrentPendingApproval(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                                                "현재 결재 대기 중인 상태가 아닙니다."));

                // 🛡️ 보안 검증: 현재 결재 순서인 사람과 로그인한 사람이 일치하는가?
                if (!currentPendingApproval.getApproverId().equals(approverId)) {
                        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인의 결재 순서가 아닙니다.");
                }

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

        // 상신 취소
        @Transactional
        public void recallDocument(Long docId, String userId) {
                elecApprovalMapper.recallDocument(docId, userId);
        }

        @Transactional
        public void deleteDocument(int docId, String loginId) {

                // 1. 문서 정보 조회
                DocumentRespDto document = elecApprovalMapper.selectDocumentById(docId)
                                .orElseThrow(() -> new RuntimeException("삭제할 문서를 찾을 수 없습니다."));

                // 2. 권한 체크: 기안자 본인만 삭제 가능
                if (!document.getInitiatorId().equals(loginId)) {
                        throw new RuntimeException("본인이 작성한 문서만 삭제할 수 있습니다.");
                }

                // 3. 상태 체크: 상신취소(RECALLED) 상태일 때만 삭제 허용
                if (!DocumentStatus.RECALLED.equals(document.getStatus())) {
                        throw new RuntimeException("상신취소 상태인 문서만 삭제가 가능합니다.");
                }

                // 4. 연관 데이터 삭제: 결재 이력(History)을 먼저 삭제해야 외래키 오류가 발생하지 않음
                elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

                // 5. 첨부파일 삭제
                deleteAttachmentsByDocId(docId);

                // 6. 문서 삭제
                elecApprovalMapper.deleteDocument(docId);

                log.info("문서 및 결재선 삭제 완료 - 문서ID: {}, 실행자: {}", docId, loginId);
        }

        public List<MyLineResponseDto> findMyApprovalLines(String userId) {
                return myApprovalLineMapper.findMyApprovalLines(userId);
        }

        @Transactional
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

        @Transactional
        public void deleteMyApprovalLine(String userId, int lineId) {
                myApprovalLineMapper.deleteMyApprovalLine(userId, lineId);
                myApprovalLineMapper.deleteMyApprovalLineDetail(lineId);
        }

        @Transactional
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
                if (request.getApproverIds() != null && !request.getApproverIds().isEmpty()) {
                        List<ElecApprovalHistoryEntity> histories = new ArrayList<>();
                        List<String> approverIds = request.getApproverIds();

                        for (int i = 0; i < approverIds.size(); i++) {
                                histories.add(ElecApprovalHistoryEntity.builder()
                                                .docId(docId)
                                                .approverId(approverIds.get(i))
                                                .approvalStatus(i == 0 ? ApprovalStatus.PENDING : ApprovalStatus.WAIT)
                                                .approvalOrder(i + 1)
                                                .build());
                        }
                        elecApprovalHistoryMapper.insertApprovalHistoryEntities(histories);

                        // 첫 번째 결재자에게 알림 전송
                        String firstApproverId = histories.get(0).getApproverId();
                        notificationService.send(firstApproverId, documentEntity.getTitle(),
                                        "새로운 결재문서가 도착했습니다: " + documentEntity.getDocType().getDisplayName(),
                                        "/elecApproval/detail/" + docId);
                }

                // 4. 파일 저장
                if (files != null && !files.isEmpty()) {
                        saveFilesAndAttachment(docId, files);
                }
        }

        private void saveFilesAndAttachment(int docId, List<MultipartFile> files) {
                File dir = new File(uploadDir);
                log.info("uploadDir: {}", uploadDir);
                if (!dir.exists())
                        dir.mkdirs();

                for (MultipartFile file : files) {
                        if (file.isEmpty())
                                continue;

                        String originName = file.getOriginalFilename();
                        String savedName = UUID.randomUUID().toString() + "_" + originName;
                        File dest = new File(dir, savedName);

                        try {
                                file.transferTo(dest);
                                AttachmentEntity attachment = AttachmentEntity.builder()
                                                .docId(docId)
                                                .originName(originName)
                                                .savedName(savedName)
                                                .filePath(dest.getAbsolutePath())
                                                .fileSize(file.getSize())
                                                .build();
                                log.info("attachment: {}", attachment);
                                elecApprovalMapper.insertAttachment(attachment);
                        } catch (IOException e) {
                                throw new RuntimeException("파일 업로드 중 오류 발생", e);
                        }
                }
        }

        public AttachmentEntity getAttachment(Long fileId) {

                return elecApprovalMapper.selectAttachmentByDocId(fileId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "파일을 찾을 수 없습니다."));
        }

        // 임시저장
        @Transactional
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
                if (request.getApproverIds() != null && !request.getApproverIds().isEmpty()) {
                        List<ElecApprovalHistoryEntity> histories = new ArrayList<>();
                        List<String> approverIds = request.getApproverIds();

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

                // 4. 파일 저장
                if (files != null && !files.isEmpty()) {
                        saveFilesAndAttachment(docId, files);
                }
        }

        // 임시저장 업데이트
        @Transactional
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
                        saveFilesAndAttachment(docId, files);
                }

                deleteAttachmentsAndFiles(deleteFileIds);
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

        public DocumentRespDto getDocumentById(int docId, String username, boolean isAdmin) {
                DocumentRespDto documentRespDto = elecApprovalMapper.selectDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

                List<AttachmentEntity> attachments = elecApprovalMapper.selectAttachmentsByDocId(docId);
                documentRespDto.setAttachments(attachments);

                return documentRespDto;
        }

        @Transactional
        public void redraftDocument(int docId, DocumentReqDto request, List<MultipartFile> files,
                        List<Long> deleteFileIds, String username) {
                // 문서 가져오기 및 권한 체크
                DocumentRespDto document = elecApprovalMapper.selectDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

                if (!document.getInitiatorId().equals(username)) {
                        throw new UnauthorizedException(HttpStatus.FORBIDDEN, "본인의 문서만 재상신할 수 있습니다.");
                }

                // 문서 정보 업데이트 (제목, 내용, 상태 -> PENDING)
                document.setTitle(request.getTitle());
                document.setJsonContent(request.getJsonContent());
                document.setStatus(DocumentStatus.PENDING);

                elecApprovalMapper.updateDocumentForRedraft(document);

                // 파일 저장 (새로 추가된 파일이 있는 경우)
                if (files != null && !files.isEmpty()) {
                        saveFilesAndAttachment(docId, files);
                }

                // 첨부파일+ DB 삭제
                deleteAttachmentsAndFiles(deleteFileIds);

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

        // 첨부파일 삭제
        private void deleteFileFromDisk(String savedName) {
                File file = new File(uploadDir, savedName);
                if (file.exists()) {
                        file.delete();
                }
        }

        // 첨부파일+ DB 삭제
        private void deleteAttachmentsAndFiles(List<Long> deleteFileIds) {
                if (deleteFileIds != null && !deleteFileIds.isEmpty()) {
                        // A. 실제 파일 삭제 (로컬 디스크)
                        List<AttachmentEntity> filesToDelete = elecApprovalMapper.selectAllByIds(deleteFileIds);
                        for (AttachmentEntity file : filesToDelete) {
                                deleteFileFromDisk(file.getSavedName()); // 파일 삭제 유틸 메서드 호출
                        }
                        // B. DB 데이터 삭제
                        elecApprovalMapper.deleteByIds(deleteFileIds);
                }
        }

        // docId로 첨부파일 DB 삭제
        private void deleteAttachmentsByDocId(int docId) {
                List<AttachmentEntity> attachments = elecApprovalMapper.selectAttachmentsByDocId(docId);
                if (attachments != null && !attachments.isEmpty()) {
                        for (AttachmentEntity attachment : attachments) {
                                File file = new File(attachment.getFilePath());
                                if (file.exists()) {
                                        file.delete();
                                }
                        }
                        elecApprovalMapper.deleteAttachmentsByDocId(docId);
                }
        }

        // 결재선 생성
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
