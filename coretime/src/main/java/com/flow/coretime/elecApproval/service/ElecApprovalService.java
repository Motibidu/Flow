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
import com.flow.coretime.users.mapper.UserMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
@Service
public class ElecApprovalService {

        private final ElecApprovalMapper elecApprovalMapper;
        private final ElecApprovalHistoryMapper elecApprovalHistoryMapper;
        private final ElecApprovalLineConfigMapper elecApprovalLineConfigMapper;
        private final UserMapper userMapper;

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
        public void createDocumentAndInitialApproval(Document document, String initialApproverId) {
                // 1. 문서 저장 (DOC_ID 생성)
                elecApprovalMapper.insertDocument(document);

                // 2. 결재선 생성
                List<ElecApprovalHistory> histories = createApprovalLineHistory(document);

                // 3. 결재선 저장
                elecApprovalHistoryMapper.insertApprovalHistories(histories);
        }

        List<ElecApprovalHistory> createApprovalLineHistory(Document document) {
                // 2. 해당 문서 타입의 고정 결재선 설정 가져오기
                List<ElecApprovalLineConfig> configs = elecApprovalLineConfigMapper
                                .getApprovalConfigList(document.getDocType());

                if (configs == null || configs.isEmpty()) {
                        throw new RuntimeException("해당 문서 양식에 설정된 결재선이 없습니다.");
                }

                // 3. 설정을 바탕으로 실제 결재자들을 찾아 History 리스트 생성
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
                Document documentDetail = elecApprovalMapper.getDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));

                ElecApprovalHistory currentPendingApproval = elecApprovalHistoryMapper.findCurrentPendingApproval(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                                                "현재 결재 대기 중인 상태가 아닙니다."));

                log.info("currentPendingApprovla: {}", currentPendingApproval);

                // 🛡️ 보안 검증: 현재 결재 순서인 사람과 로그인한 사람이 일치하는가?
                if (!currentPendingApproval.getApproverId().equals(approverId)) {
                        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인의 결재 순서가 아닙니다.");
                }

                // 2. 현재 결재 단계 업데이트 (승인 또는 반려)
                currentPendingApproval.setAction(action);
                currentPendingApproval.setCommentText(comment);
                currentPendingApproval.setActionDate(new Date()); // 실제 결재 시점 기록
                elecApprovalHistoryMapper.updateApprovalHistory(currentPendingApproval);

                // 3. 결재 액션에 따른 후속 처리
                if ("APPROVED".equals(action)) {
                        // 다음 결재자 찾기
                        Optional<ElecApprovalHistory> nextApproverOpt = elecApprovalHistoryMapper.findNextApprover(
                                        docId, currentPendingApproval.getApprovalOrder());

                        if (nextApproverOpt.isPresent()) {
                                // 다음 결재자가 있는 경우: 상태를 PENDING으로 활성화
                                ElecApprovalHistory nextApprover = nextApproverOpt.get();
                                nextApprover.setAction("PENDING");
                                // nextApprover.setActionDate(null); // 아직 결재 전이므로 null 유지
                                elecApprovalHistoryMapper.updateApprovalHistory(nextApprover);

                                documentDetail.setStatus("IN_PROGRESS");
                        } else {
                                // 더 이상 결재자가 없는 경우: 최종 승인 완료
                                documentDetail.setStatus("APPROVED");
                        }
                } else if ("REJECTED".equals(action)) {
                        // 반려인 경우: 문서 상태 변경 및 이후 결재선은 무시됨
                        documentDetail.setStatus("REJECTED");
                }

                // 4. 문서 최종 상태 반영
                documentDetail.setUpdatedAt(new Date());
                elecApprovalMapper.updateDocumentStatus(documentDetail);
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
        public void redraftDocument(Long docId, Document redraftData) {

                log.info("redraftData: {}", redraftData);

                // 1. 기존 문서의 상태를 'PENDING'으로 변경하고 내용 업데이트
                redraftData.setDocId(docId.intValue());
                redraftData.setStatus("PENDING");
                int updated = elecApprovalMapper.updateDocumentForRedraft(redraftData);

                if (updated == 0) {
                        log.info("여기가 에러다");
                        throw new RuntimeException("문서 수정 권한이 없거나 수정할 수 없는 상태입니다.");
                }
                log.info("1");

                // 2. 기존 결재 이력 삭제 (상신 취소나 반려 시 쌓였던 이력을 지우고 새로 시작)
                elecApprovalHistoryMapper.deleteHistoryByDocId(docId);
                log.info("2");

                // 3. 결재선 생성
                List<ElecApprovalHistory> histories = createApprovalLineHistory(redraftData);
                log.info("3");

                // 4. 결재선 저장
                elecApprovalHistoryMapper.insertApprovalHistories(histories);
                log.info("4");
        }

}
