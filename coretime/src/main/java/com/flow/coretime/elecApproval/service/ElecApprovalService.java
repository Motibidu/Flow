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
import com.flow.coretime.elecApproval.model.ElecApprovalHistory;
import com.flow.coretime.elecApproval.model.ElecApprovalHistoryEntity;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfigEntity;
import com.flow.coretime.elecApproval.model.MyApprovalLineDetailEntity;
import com.flow.coretime.elecApproval.model.MyApprovalLineEntity;
import com.flow.coretime.elecApproval.model.MyLineResponseDto;
import com.flow.coretime.elecApproval.model.MyLineSaveDto;
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

        // 전자결재 등록하기
        @Transactional
        public void createDocumentAndInitialApproval(DocumentRespDto document, String loginId) {
                // 1. 기안자 정보 상세 조회
                User initiator = userService.findById(loginId)
                                .orElseThrow(() -> new RuntimeException("기안자 정보를 찾을 수 없습니다."));

                // 2. 누락된 필드 채우기
                document.setInitiatorId(initiator.getId());
                document.setInitiatorName(initiator.getName());
                document.setInitiatorRank(initiator.getRank());
                document.setInitiatorDepartment(initiator.getDepartment());

                document.setDraftDate(new Date());
                document.setUpdatedAt(new Date());
                document.setStatus(DocumentStatus.PENDING);

                // 3. 문서 저장 (DB insert 후 DOC_ID가 생성됨)
                elecApprovalMapper.insertDocument(document);

                // 4. 결재선 생성 및 저장
                List<ElecApprovalHistory> histories = createApprovalLineHistory(document);
                elecApprovalHistoryMapper.insertApprovalHistories(histories);

                // 5. 첫 번째 결재자에게 알림 전송
                if (!histories.isEmpty()) {
                        String firstApproverId = histories.get(0).getApproverId();
                        log.info("첫 번째 결재자 알림 발송 대상: {}", firstApproverId);

                        notificationService.send(firstApproverId, document.getTitle(),
                                        "새로운 결재문서가 도착했습니다: " + document.getDocType().getDisplayName(),
                                        "/elecApproval/detail/" + document.getDocId());
                }
        }

        public List<ElecApprovalHistory> createApprovalLineHistory(DocumentRespDto document) {
                // 1. 해당 문서 타입의 고정 결재선 가져오기
                List<ElecApprovalLineConfigEntity> configs = elecApprovalLineConfigMapper
                                .getApprovalConfigList(document.getDocType());

                if (configs == null || configs.isEmpty()) {
                        throw new RuntimeException("해당 문서 양식에 설정된 결재선이 없습니다.");
                }

                // 2. 설정을 바탕으로 실제 결재자들을 찾아 History 리스트 생성
                return configs.stream().map(config -> {

                        DepartmentType targetDepartment = config.getDepartment();
                        PositionType targetPosition = config.getPosition();

                        // 1. 실제 결재자 ID 조회
                        String actualApproverId = userMapper
                                        .findUserByDepartmentAndPosition(document.getInitiatorDepartment(),
                                                        config.getPosition())
                                        .orElseThrow(() -> new RuntimeException(
                                                        String.format("[%s] 부서에 [%s] 직급자가 존재하지 않아 결재선을 생성할 수 없습니다.",
                                                                        targetDepartment.getDisplayName(),
                                                                        targetPosition.getDisplayName())));

                        // 3. ElecApprovalHistory 객체 생성 및 반환
                        return ElecApprovalHistory.builder()
                                        .docId(document.getDocId())
                                        .approverId(actualApproverId)
                                        .approvalOrder(config.getApprovalOrder())
                                        .approvalStatus(config.getApprovalOrder() == 1 ? ApprovalStatus.PENDING
                                                        : ApprovalStatus.WAIT)
                                        .build();

                }).collect(Collectors.toList());

        }

        public DocumentRespDto getDocumentById(int docId) {
                DocumentRespDto documentRespDto = elecApprovalMapper.getDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));
                List<AttachmentEntity> attachments = elecApprovalMapper.selectAttachmentsByDocId(docId);
                documentRespDto.setAttachments(attachments);

                return documentRespDto;

        }

        // 문서의 현재 PENDING 상태 결재자 ID 조회
        public String getCurrentApproverIdForDocument(int docId) {
                Optional<ElecApprovalHistory> currentPendingApproval = elecApprovalHistoryMapper
                                .findCurrentPendingApproval(docId);
                return currentPendingApproval.map(ElecApprovalHistory::getApproverId).orElse(null);
        }

        // 문서의 모든 결재 이력 조회 (JSP에서 결재선 동적 표시용)
        public List<ElecApprovalHistory> getApprovalHistoriesForDocument(int docId) {
                return elecApprovalHistoryMapper.findApprovalHistoryByDocId(docId);
        }

        // 결재하기
        @Transactional
        public void processApproval(int docId, String approverId, ApprovalStatus approvalStatus, String comment) {

                // 1. 문서 조회
                DocumentRespDto document = elecApprovalMapper.getDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

                // 2. 현재 결재자 조회
                ElecApprovalHistory currentPendingApproval = elecApprovalHistoryMapper.findCurrentPendingApproval(docId)
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
                        Optional<ElecApprovalHistory> nextApprovalHistoryOpt = elecApprovalHistoryMapper
                                        .findNextApprover(
                                                        docId, currentPendingApproval.getApprovalOrder());
                        // 4-1. 다음 결재자가 있는 경우: 상태를 PENDING으로 활성화
                        if (nextApprovalHistoryOpt.isPresent()) {

                                ElecApprovalHistory nextApprovalHistory = nextApprovalHistoryOpt.get();
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
        public void withdrawApproval(Long docId, String userId) {
                Map<String, Object> params = new HashMap<>();
                params.put("docId", docId);
                params.put("userId", userId);

                // 1. 문서 상태 업데이트
                int result = elecApprovalMapper.cancelApproval(params);

                // 결과가 0이면 조건(본인 아님 또는 이미 결재됨)에 맞지 않는 것
                if (result == 0) {
                        throw new IllegalStateException("취소 가능한 상태가 아니거나 권한이 없습니다.");
                }

                // 2. 결재선 데이터 삭제
                elecApprovalMapper.deletePendingHistory(docId);
        }

        @Transactional
        public void redraftDocument(String userId, int docId, DocumentRespDto redraftDocument) {
                DocumentRespDto document = getDocumentById(docId);

                // 1. 기안자의 부서 정보 가져오기
                User initiator = userMapper.findById(userId)
                                .orElseThrow(() -> new RuntimeException("기안자 정보를 찾을 수 없습니다."));

                // 2. redraftData에 기안자의 부서 정보 설정
                redraftDocument.setInitiatorDepartment(initiator.getDepartment());
                redraftDocument.setStatus(DocumentStatus.PENDING);
                redraftDocument.setDocId(docId);

                elecApprovalMapper.updateDocumentForRedraft(redraftDocument);

                // 4. 기존 결재 이력 삭제 (상신 취소나 반려 시 쌓였던 이력을 지우고 새로 시작)
                elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

                // 5. 결재선 생성
                List<ElecApprovalHistory> histories = createApprovalLineHistory(redraftDocument);

                // 6. 결재선 저장
                elecApprovalHistoryMapper.insertApprovalHistories(histories);

                // 7. 웹소켓 메시지 전송
                String firstApproverId = histories.get(0).getApproverId();

                // 8. 결재자에게 SSE 메시지 전송
                notificationService.send(firstApproverId, redraftDocument.getTitle(),
                                "새로운 결재문서가 도착했습니다." + redraftDocument.getDocType(),
                                "/elecApproval/detail/" + docId);
        }

        @Transactional
        public void deleteDocument(int docId, String loginId) {

                // 1. 문서 정보 조회
                DocumentRespDto document = elecApprovalMapper.getDocumentById(docId)
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

                // 5. 문서 삭제
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

        public void deleteMyApprovalLine(String userId, int lineId) {
                myApprovalLineMapper.deleteMyApprovalLine(userId, lineId);
                myApprovalLineMapper.deleteMyApprovalLineDetail(lineId);
        }

        public void saveDocumentAndApprovalLine(DocumentReqDto documentReqDTO, String loginId) {
                // 1. 문서 엔티티 생성
                DocumentEntity documentEntity = DocumentEntity.builder()
                                .docType(documentReqDTO.getDocType())
                                .title(documentReqDTO.getTitle())
                                .jsonContent(documentReqDTO.getJsonContent())
                                .initiatorId(loginId)
                                .status(DocumentStatus.PENDING)
                                .draftDate(new Date())
                                .updatedAt(new Date())
                                .build();

                // 2. 문서 저장
                elecApprovalMapper.insertDocumentEntity(documentEntity);

                // 3. 결재선 생성 및 저장
                List<ElecApprovalHistoryEntity> histories = new ArrayList<>();
                documentReqDTO.getApproverIds().stream().forEach(approverId -> {
                        ElecApprovalHistoryEntity history = ElecApprovalHistoryEntity.builder()
                                        .docId(documentEntity.getDocId())
                                        .approverId(approverId)
                                        .approvalStatus(documentReqDTO.getApproverIds().indexOf(approverId) == 0
                                                        ? ApprovalStatus.PENDING
                                                        : ApprovalStatus.WAIT)
                                        .approvalOrder(documentReqDTO.getApproverIds().indexOf(approverId) + 1)
                                        .build();
                        histories.add(history);
                });
                elecApprovalHistoryMapper.insertApprovalHistoryEntities(histories);

                // 4. 첫 번째 결재자에게 알림 전송
                if (!histories.isEmpty()) {
                        String firstApproverId = histories.get(0).getApproverId();
                        log.info("첫 번째 결재자 알림 발송 대상: {}", firstApproverId);

                        notificationService.send(firstApproverId, documentEntity.getTitle(),
                                        "새로운 결재문서가 도착했습니다: " + documentEntity.getDocType().getDisplayName(),
                                        "/elecApproval/detail/" + documentEntity.getDocId());
                }

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
                        saveFiles(docId, files);
                }
        }

        private void saveFiles(int docId, List<MultipartFile> files) {
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
                        saveFiles(docId, files);
                }
        }

        // 임시저자장 업데이트
        public void updateTempDocument(int docId, DocumentReqDto request, List<MultipartFile> files, String loginId) {

                // 1. 문서 엔티티 생성
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

                // 2. 문서 저장
                elecApprovalMapper.updateTempDocumentEntity(documentEntity);

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
                        saveFiles(docId, files);
                }
        }

        public List<DocumentRespDto> findAllPendingOrInProgress(String username) {
                return elecApprovalMapper.selectAllPendingOrInProgress(username);
        }

        public List<DocumentRespDto> findAllRejectedOrRecalled(String username) {
                return elecApprovalMapper.selectAllRejectedOrRecalled(username);
        }

        public List<DocumentRespDto> findAllApproved(String username) {
                return elecApprovalMapper.selectAllApproved(username);
        }

        public List<DocumentRespDto> findAllTemp(String username) {
                return elecApprovalMapper.selectAllTemp(username);
        }

        public List<DocumentRespDto> findAllMyTurn(String username) {
                return elecApprovalMapper.selectAllMyTurn(username);

        }
}
