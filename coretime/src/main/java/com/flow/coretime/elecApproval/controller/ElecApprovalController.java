package com.flow.coretime.elecApproval.controller;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;

import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.mapper.ElecApprovalLineConfigMapper;
import com.flow.coretime.elecApproval.model.ApprovalReq;
import com.flow.coretime.elecApproval.model.Document;
import com.flow.coretime.elecApproval.model.ElecApprovalHistory;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfig;
import com.flow.coretime.elecApproval.service.ElecApprovalService;
import com.flow.coretime.users.model.User;
import com.flow.coretime.users.service.UserService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/elecApproval")
public class ElecApprovalController {

        private final ElecApprovalLineConfigMapper elecApprovalLineConfigMapper;
        private final ElecApprovalService elecApprovalService;
        private final UserService userService;

        @GetMapping
        public String showElecApproval(@AuthenticationPrincipal UserDetails userDetails, Model model) {
                String currentUserId = userDetails.getUsername();

                List<Document> pendingApprovals = elecApprovalService.getPendingApprovals(currentUserId);
                model.addAttribute("pendingApprovals", pendingApprovals);

                // 내가 기안한 진행 중 문서
                List<Document> myInProgressDocs = elecApprovalService.selectMyInProgressDocs(currentUserId);
                model.addAttribute("myInProgressDocs", myInProgressDocs);

                List<Document> rejectedOrRecalled = elecApprovalService.selectRejectedOrRecalledDocs(currentUserId);
                model.addAttribute("myRejectedOrRecalledDocs", rejectedOrRecalled);

                List<Document> myApprovedDocs = elecApprovalService.selectMyApprovedDocs(currentUserId);
                model.addAttribute("myApprovedDocs", myApprovedDocs);

                return "elecApproval";
        }

        @GetMapping("/new")
        public String showElecApprovalNew(@RequestParam("formType") String formType,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {
                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUserName", currentUser.getName());
                model.addAttribute("currentUserDepartment", currentUser.getDepartment().getDisplayName());

                if (DocumentType.VACATION_REQUEST.toString().equals(formType)) {
                        List<ElecApprovalLineConfig> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalConfigList(DocumentType.VACATION_REQUEST);
                        log.info("approvalLines: {}", approvalLines);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/vacationRequestForm";
                } else if (DocumentType.EXPENSE_REPORT.toString().equals(formType)) {
                        List<ElecApprovalLineConfig> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalConfigList(DocumentType.EXPENSE_REPORT);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/expenseReportForm";
                } else if (DocumentType.GENERAL_PROPOSAL.toString().equals(formType)) {
                        List<ElecApprovalLineConfig> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalConfigList(DocumentType.GENERAL_PROPOSAL);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/generalProposalForm";
                }

                return "elecApproval/elecApprovalNew";

        }

        @PostMapping("/documents")
        public String createElecApprovalNew(@RequestBody Document document,
                        @AuthenticationPrincipal UserDetails userDetails) {
                log.info("document: {}", document);

                // 1. 최소한의 사용자 식별 정보만 가져옴
                String loginId = userDetails.getUsername();

                // 2. 비즈니스 로직은 Service에 전임 (document 객체와 기안자 ID만 전달)
                elecApprovalService.createDocumentAndInitialApproval(document, loginId);

                return "redirect:/elecApproval";
        }

        @GetMapping("/detail/{docId}")
        public String detailElecApproval(@PathVariable("docId") int docId,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {

                Document document = elecApprovalService.getDocumentById(docId);
                model.addAttribute("document", document);

                List<ElecApprovalHistory> approvalHistories = elecApprovalService
                                .getApprovalHistoriesForDocument(docId);
                model.addAttribute("approvalHistories", approvalHistories);

                // 결재할 차례의 사람이면 승인/반려 버튼 활성화
                String currentApproverId = approvalHistories.stream()
                                .filter(h -> ApprovalStatus.PENDING.equals(h.getApprovalStatus()))
                                .findFirst()
                                .map(ElecApprovalHistory::getApproverId)
                                .orElse(null);
                model.addAttribute("currentApproverId", currentApproverId);

                // 기안자 본인이면 상신취소 또는 재기안 버튼 활성화
                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUser", currentUser);

                // log.info("document: {}", document);
                // log.info("approvalHistories: {}", approvalHistories);
                // log.info("currentApproverId: {}", currentApproverId);
                // log.info("currentUser: {}", currentUser);

                if (DocumentType.VACATION_REQUEST.equals(document.getDocType())) {
                        return "elecApproval/vacationRequestDetail";
                } else if (DocumentType.EXPENSE_REPORT.equals(document.getDocType())) {
                        return "elecApproval/expenseReportDetail";
                } else if (DocumentType.GENERAL_PROPOSAL.equals(document.getDocType())) {
                        return "elecApproval/generalProposalDetail";
                }

                return "vacationRequestDetail";
        }

        @GetMapping("/redraft/{docId}")
        public String showEditForm(@PathVariable("docId") int docId, Model model) {
                Document document = elecApprovalService.getDocumentById(docId);
                log.info("document: {}", document);
                model.addAttribute("document", document);

                DocumentType documentType = document.getDocType();
                if (DocumentType.VACATION_REQUEST.equals(documentType)) {
                        return "elecApproval/vacationRequestForm";
                } else if (DocumentType.EXPENSE_REPORT.equals(documentType)) {
                        return "elecApproval/expenseReportForm";
                } else if (DocumentType.GENERAL_PROPOSAL.equals(documentType)) {
                        return "elecApproval/generalProposalForm";
                }

                return "elecApproval/vacationEditForm";
        }

        @ResponseBody
        @PostMapping("/redraft/{docId}")
        public String redraftDocument(@PathVariable("docId") int docId,
                        @RequestBody Document redraftData,
                        @AuthenticationPrincipal UserDetails userDetails) {
                log.info("redraftData: {}", redraftData);
                String userId = userDetails.getUsername();
                elecApprovalService.redraftDocument(userId, docId, redraftData);

                return "redirect:/elecApproval/detail/" + docId;
        }

        @PostMapping("/approval/{docId}")
        @ResponseBody // JSON 응답을 위해
        public ResponseEntity<Map<String, String>> approveOrRejectDocument(
                        @PathVariable("docId") int docId,
                        @RequestBody ApprovalReq approvalReq,
                        @AuthenticationPrincipal UserDetails userDetails) {

                ApprovalStatus approvalStatus = ApprovalStatus.fromString(approvalReq.getAction());
                String comment = approvalReq.getComment();

                // 반려 시 의견 필수 검증
                approvalStatus.validateCommentWhenRejected(comment);

                String approverId = userDetails.getUsername();
                elecApprovalService.processApproval(docId, approverId, approvalStatus, comment);

                // 3. 성공 응답만 리턴
                String successMessage = (approvalStatus == ApprovalStatus.APPROVED) ? "결재가 승인되었습니다." : "결재가 반려되었습니다.";
                return ResponseEntity.ok(Map.of("status", "success", "message", successMessage));
        }

        @PostMapping("/recall/{docId}")
        @ResponseBody
        public ResponseEntity<Map<String, String>> recall(@PathVariable(name = "docId") Long docId,
                        @AuthenticationPrincipal UserDetails userDetails) {
                Map<String, String> response = new HashMap<>();
                try {
                        elecApprovalService.withdrawApproval(docId, userDetails.getUsername());
                        response.put("message", "상신 취소가 성공적으로 완료되었습니다.");
                        return ResponseEntity.ok(response);
                } catch (Exception e) {
                        response.put("message", e.getMessage());
                        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
                }
        }

        @DeleteMapping("/delete/{docId}")
        public ResponseEntity<Map<String, String>> deleteDocument(
                        @PathVariable(name = "docId") int docId,
                        @AuthenticationPrincipal UserDetails userDetails) {
                try {
                        elecApprovalService.deleteDocument(docId, userDetails.getUsername());
                        return ResponseEntity.ok(Collections.singletonMap("message", "문서가 성공적으로 삭제되었습니다."));
                } catch (Exception e) {
                        log.error("문서 삭제 중 오류가 발생했습니다.", e);
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                        .body(Collections.singletonMap("message", e.getMessage()));
                }
        }

}
