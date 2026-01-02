package com.flow.coretime.elecApproval.service;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.flow.coretime.elecApproval.mapper.ElecApprovalMapper;
import com.flow.coretime.elecApproval.mapper.ElecApprovalHistoryMapper;
import com.flow.coretime.elecApproval.mapper.ElecApprovalLineConfigMapper;
import com.flow.coretime.elecApproval.model.Document;
import com.flow.coretime.elecApproval.model.ElecApprovalHistory;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfig;
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

        private final UserService userService;

        private final ElecApprovalMapper elecApprovalMapper;
        private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
        private final ElecApprovalLineConfigMapper elecApprovalLineConfigMapper;
        private final UserMapper userMapper;
        private final NotificationService notificationService;

        // 수신자의 결재대기 목록, docId를
        public List<Document> getPendingApprovals(String currentUserId) {
                return elecApprovalMapper.findPendingApprovalsByApproverId(currentUserId);
        }

        // 상신자의 결재대기 목록
        public List<Document> getMyInProgressDocs(String currentUserId) {
                return elecApprovalMapper.findInProgressDocumentsByInitiatorId(currentUserId);
        }

        // 상신자의 결재승인 목록
        public List<Document> getMyApprovedDocs(String currentUserId) {
                return elecApprovalMapper.findApprovedDocumentsByInitiatorId(currentUserId);
        }

        public void createDocument(Document document) {
                elecApprovalMapper.insertDocument(document);
        }

        // 전자결재 등록하기
        @Transactional
        public void createDocumentAndInitialApproval(Document documentDetail, String loginId) {
                // 1. 기안자 정보 상세 조회 (이름, 부서 등)
                User initiator = userService.findById(loginId)
                                .orElseThrow(() -> new RuntimeException("기안자 정보를 찾을 수 없습니다."));

                // 2. 누락된 필드 채우기 (Service 담당)
                documentDetail.setInitiatorId(initiator.getId());
                documentDetail.setInitiatorName(initiator.getName());
                documentDetail.setInitiatorRank(initiator.getRankName());
                documentDetail.setInitiatorDepartment(initiator.getDepartment());

                documentDetail.setDraftDate(new Date());
                documentDetail.setUpdatedAt(new Date());
                documentDetail.setStatus("PENDING");

                // [중요] 제목이 null로 넘어올 경우를 대비한 방어 로직
                if (documentDetail.getTitle() == null || documentDetail.getTitle().trim().isEmpty()) {
                        String autoTitle = String.format("[%s] %s님의 결재 요청",
                                        documentDetail.getDocType(), initiator.getName());
                        documentDetail.setTitle(autoTitle);
                }

                // 3. 문서 저장 (DB insert 후 DOC_ID가 생성됨)
                elecApprovalMapper.insertDocument(documentDetail);

                // 4. 결재선 생성 및 저장
                List<ElecApprovalHistory> histories = createApprovalLineHistory(documentDetail);
                elecApprovalHistoryMapper.insertApprovalHistories(histories);

                // 5. 첫 번째 결재자에게 알림 전송
                if (!histories.isEmpty()) {
                        String firstApproverId = histories.get(0).getApproverId();
                        log.info("첫 번째 결재자 알림 발송 대상: {}", firstApproverId);

                        notificationService.send(firstApproverId, documentDetail.getTitle(),
                                        "새로운 결재문서가 도착했습니다: " + documentDetail.getDocType().getDisplayName(),
                                        "/elecApproval/detail/" + documentDetail.getDocId());
                }
        }

        public List<ElecApprovalHistory> createApprovalLineHistory(Document document) {
                // 1. 해당 문서 타입의 고정 결재선 설정 가져오기
                List<ElecApprovalLineConfig> configs = elecApprovalLineConfigMapper
                                .getApprovalConfigList(document.getDocType());

                if (configs == null || configs.isEmpty()) {
                        throw new RuntimeException("해당 문서 양식에 설정된 결재선이 없습니다.");
                }

                // 2. 설정을 바탕으로 실제 결재자들을 찾아 History 리스트 생성
                return configs.stream().map(config -> {

                        // 1. 부서 결정 (삼항 연산자로 간결화)
                        String targetDept = "MY_DEPT".equals(config.getDeptType())
                                        ? document.getInitiatorDepartment()
                                        : config.getDeptType();

                        // 2. 실제 결재자 ID 조회
                        String actualApproverId = userMapper.findUserByDeptAndRank(targetDept, config.getTargetRank())
                                        .orElseThrow(() -> new RuntimeException(
                                                        String.format("[%s] 부서에 [%s] 직급자가 존재하지 않아 결재선을 생성할 수 없습니다.",
                                                                        targetDept, config.getTargetRank())));

                        // 3. ElecApprovalHistory 객체 생성 및 반환
                        return ElecApprovalHistory.builder()
                                        .docId(document.getDocId())
                                        .approverId(actualApproverId)
                                        .approvalOrder(config.getApprovalOrder())
                                        .action(config.getApprovalOrder() == 1 ? "PENDING" : "WAIT")
                                        .build();

                }).collect(Collectors.toList());

        }

        // public Document getDocumentById(int docId) {
        // return elecApprovalMapper.getDocumentById(docId);
        // }

        public Optional<Document> getDocumentById(int docId) {
                return elecApprovalMapper.getDocumentById(docId);
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
        public void processApproval(int docId, String approverId, String action, String comment) {

                // 1. 문서 및 현재 결재 단계 조회
                Document document = elecApprovalMapper.getDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

                ElecApprovalHistory currentPendingApproval = elecApprovalHistoryMapper.findCurrentPendingApproval(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                                                "현재 결재 대기 중인 상태가 아닙니다."));

                log.info("approverId: {}", approverId);

                // 🛡️ 보안 검증: 현재 결재 순서인 사람과 로그인한 사람이 일치하는가?
                if (!currentPendingApproval.getApproverId().equals(approverId)) {
                        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인의 결재 순서가 아닙니다.");
                }

                // 2. 현재 결재 단계 업데이트 (승인 또는 반려)
                currentPendingApproval.setAction(action);
                currentPendingApproval.setCommentText(comment);
                currentPendingApproval.setActionDate(new Date()); // 실제 결재 시점 기록
                elecApprovalHistoryMapper.updateApprovalHistory(currentPendingApproval);

                // 3. '결재'인 경우
                if ("APPROVED".equals(action)) {
                        Optional<ElecApprovalHistory> nextApprovalHistoryOpt = elecApprovalHistoryMapper
                                        .findNextApprover(
                                                        docId, currentPendingApproval.getApprovalOrder());

                        if (nextApprovalHistoryOpt.isPresent()) {
                                // 다음 결재자가 있는 경우: 상태를 PENDING으로 활성화
                                ElecApprovalHistory nextApprovalHistory = nextApprovalHistoryOpt.get();
                                nextApprovalHistory.setAction("PENDING");
                                nextApprovalHistory.setActionDate(null);
                                elecApprovalHistoryMapper.updateApprovalHistory(nextApprovalHistory);

                                document.setStatus("IN_PROGRESS");

                                notificationService.send(nextApprovalHistory.getApproverId(), document.getTitle(),
                                                "결재 대기: '" + document.getDocType() + "' 문서의 승인 차례입니다.",
                                                "/elecApproval/detail/" + document.getDocId());
                        } else {
                                // 더 이상 결재자가 없는 경우: 최종 승인 완료
                                document.setStatus("APPROVED");

                                notificationService.send(document.getInitiatorId(), document.getTitle(),
                                                "결재 완료: '" + document.getDocType() + "' 문서가 최종 승인되었습니다! 🎉",
                                                "/elecApproval/detail/" + document.getDocId());
                        }
                        // 4. 반려인 경우: 문서 상태 변경 및 이후 결재선은 무시됨
                } else if ("REJECTED".equals(action)) {

                        document.setStatus("REJECTED");

                        notificationService.send(document.getInitiatorId(), document.getTitle(),
                                        "결재 반려: '" + document.getDocType() + "' 문서가 반려되었습니다. 사유를 확인해 주세요. ⚠️",
                                        "/elecApproval/detail/" + document.getDocId());
                }

                // 4. 문서 최종 상태 반영
                document.setUpdatedAt(new Date());
                elecApprovalMapper.updateDocumentStatus(document);

        }

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

        public List<Document> getRejectedOrRecalledDocs(String currentUserId) {
                return elecApprovalMapper.findRejectedOrRecalledDocuments(currentUserId);

        }

        public Document getDocumentDetail(Long docId) {
                Document document = elecApprovalMapper.getDocumentDetail(docId);

                if (document == null) {
                        throw new RuntimeException("해당 문서를 찾을 수 없습니다. (ID: " + docId + ")");
                }

                return document;
        }

        @Transactional
        public void redraftDocument(int docId, Document redfraftDocumentDetail) {

                log.info("redraftData: {}", redfraftDocumentDetail);

                // 1. 기안자의 부서 정보 가져오기
                User initiator = userMapper.findById(redfraftDocumentDetail.getInitiatorId())
                                .orElseThrow(() -> new RuntimeException("기안자 정보를 찾을 수 없습니다."));

                // 2. redraftData에 기안자의 부서 정보 설정
                redfraftDocumentDetail.setInitiatorDepartment(initiator.getDepartment());

                // 3. 기존 문서의 상태를 'PENDING'으로 변경하고 내용 업데이트
                redfraftDocumentDetail.setStatus("PENDING");
                elecApprovalMapper.updateDocumentForRedraft(redfraftDocumentDetail);

                // 4. 기존 결재 이력 삭제 (상신 취소나 반려 시 쌓였던 이력을 지우고 새로 시작)
                elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

                // 5. 결재선 생성
                List<ElecApprovalHistory> histories = createApprovalLineHistory(redfraftDocumentDetail);

                // 6. 결재선 저장
                elecApprovalHistoryMapper.insertApprovalHistories(histories);

                // 7. 웹소켓 메시지 전송
                String firstApproverId = histories.get(0).getApproverId();

                // 8. 결재자에게 SSE 메시지 전송
                notificationService.send(firstApproverId, redfraftDocumentDetail.getTitle(),
                                "새로운 결재문서가 도착했습니다." + redfraftDocumentDetail.getDocType(),
                                "/elecApproval/detail/" + docId);
        }

        @Transactional
        public void deleteDocument(int docId, String loginId) {

                // 1. 문서 정보 조회
                Document document = elecApprovalMapper.getDocumentById(docId)
                                .orElseThrow(() -> new RuntimeException("삭제할 문서를 찾을 수 없습니다."));

                // 2. 권한 체크: 기안자 본인만 삭제 가능
                if (!document.getInitiatorId().equals(loginId)) {
                        throw new RuntimeException("본인이 작성한 문서만 삭제할 수 있습니다.");
                }

                // 3. 상태 체크: 상신취소(RECALLED) 상태일 때만 삭제 허용
                if (!"RECALLED".equals(document.getStatus())) {
                        throw new RuntimeException("상신취소 상태인 문서만 삭제가 가능합니다.");
                }

                // 4. 연관 데이터 삭제: 결재 이력(History)을 먼저 삭제해야 외래키 오류가 발생하지 않음
                elecApprovalHistoryMapper.deleteHistoryByDocId(docId);

                // 5. 문서 삭제
                elecApprovalMapper.deleteDocument(docId);

                log.info("문서 및 결재선 삭제 완료 - 문서ID: {}, 실행자: {}", docId, loginId);
        }
}
