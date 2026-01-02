package com.flow.coretime.elecApproval.controller;

import java.util.Collections;
import java.util.Date;
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
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.model.Document;
import com.flow.coretime.elecApproval.model.ElecApprovalHistory;
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

        private final ElecApprovalService elecApprovalService;
        private final UserService userService;

        @GetMapping
        public String showElecApproval(@AuthenticationPrincipal UserDetails userDetails, Model model) {
                String currentUserId = userDetails.getUsername();
                

                List<Document> pendingApprovals = elecApprovalService.getPendingApprovals(currentUserId);
                model.addAttribute("pendingApprovals", pendingApprovals);

                List<Document> myInProgressDocs = elecApprovalService.getMyInProgressDocs(currentUserId);
                model.addAttribute("myInProgressDocs", myInProgressDocs);

                List<Document> myApprovedDocs = elecApprovalService.getMyApprovedDocs(currentUserId);
                model.addAttribute("myApprovedDocs", myApprovedDocs);

                List<Document> rejectedOrRecalled = elecApprovalService.getRejectedOrRecalledDocs(currentUserId);
                model.addAttribute("myRejectedOrRecalledDocs", rejectedOrRecalled);

                return "elecApproval";
        }

        @GetMapping("/new")
        public String showElecApprovalNew(@RequestParam("formType") String formType,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {
                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUserName", currentUser.getName());
                model.addAttribute("currentUserDepartment", currentUser.getDepartment());
                System.out.println("formType: " + formType);
                if (formType == "vacationRequestForm") {
                        return "vacationRequestForm";
                }
                return "elecApprovalNew";

        }

        @PostMapping("/new")
        public String showElecApprovalNew(@ModelAttribute Document document,
                        @AuthenticationPrincipal UserDetails userDetails) {

                // 1. 최소한의 사용자 식별 정보만 가져옴
                String loginId = userDetails.getUsername();

                // 2. 비즈니스 로직은 Service에 전임 (document 객체와 기안자 ID만 전달)
                elecApprovalService.createDocumentAndInitialApproval(document, loginId);

                return "redirect:/elecApproval";
        }

        @GetMapping("/detail/{docId}")
        public String detailElecApproval(@PathVariable("docId") int docId,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {

                Document documentDetail = elecApprovalService.getDocumentById(docId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다."));
                model.addAttribute("documentDetail", documentDetail);

                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUser", currentUser);

                List<ElecApprovalHistory> approvalHistories = elecApprovalService
                                .getApprovalHistoriesForDocument(docId);
                model.addAttribute("approvalHistories", approvalHistories);

                String currentApproverId = approvalHistories.stream()
                                .filter(h -> "PENDING".equals(h.getAction()))
                                .findFirst()
                                .map(ElecApprovalHistory::getApproverId)
                                .orElse(null);

                model.addAttribute("currentApproverId", currentApproverId);

                return "elecApprovalDetail";
        }

        @GetMapping("/edit/{docId}")
        public String showEditForm(@PathVariable("docId") Long docId, Model model) {
                Document document = elecApprovalService.getDocumentDetail(docId); //
                model.addAttribute("document", document);

                return "vacationEditForm";
        }

        @PostMapping("/redraft/{docId}")
        public String redraftDocument(@PathVariable("docId") int docId,
                        @ModelAttribute Document redraftData,
                        @AuthenticationPrincipal UserDetails userDetails,
                        RedirectAttributes redirectAttributes) {
                try {

                        // 1. 현재 로그인한 사용자를 기안자로 설정 (보안)
                        redraftData.setInitiatorId(userDetails.getUsername());

                        // 2. 서비스 단에서 트랜잭션 처리 (문서 수정 + 상태 변경 + 기존 이력 삭제)
                        elecApprovalService.redraftDocument(docId, redraftData);

                        // 3. 성공 메시지와 함께 리다이렉트
                        redirectAttributes.addFlashAttribute("message", "문서가 성공적으로 재상신되었습니다.");
                        return "redirect:/elecApproval";

                } catch (Exception e) {
                        // 4. 에러 발생 시 기존 수정 페이지로 돌아가며 에러 메시지 전달
                        redirectAttributes.addFlashAttribute("error", "재기안 처리 중 오류가 발생했습니다: " + e.getMessage());
                        return "redirect:/elecApproval/edit/" + docId;
                }
        }

        @PostMapping("/approval/{docId}")
        @ResponseBody // JSON 응답을 위해
        public ResponseEntity<Map<String, String>> approveOrRejectDocument(
                        @PathVariable("docId") int docId,
                        @RequestBody Map<String, String> payload, // { "action": "APPROVED", "comment": "의견" }
                        @AuthenticationPrincipal UserDetails userDetails) {

                String approverId = userDetails.getUsername();
                String action = payload.get("action"); // "APPROVED" 또는 "REJECTED"
                String comment = payload.get("comment");

                if (action == null || (!"APPROVED".equals(action) && !"REJECTED".equals(action))) {
                        return new ResponseEntity<>(
                                        Map.of("status", "error", "message", "유효하지 않은 결재 액션입니다."),
                                        HttpStatus.BAD_REQUEST);
                }

                // 반려 시 의견 필수 검증
                if ("REJECTED".equals(action) && (comment == null || comment.trim().isEmpty())) {
                        return new ResponseEntity<>(
                                        Map.of("status", "error", "message", "반려 시에는 의견을 필수로 입력해야 합니다."),
                                        HttpStatus.BAD_REQUEST);
                }

                try {
                        elecApprovalService.processApproval(docId, approverId, action, comment);
                        String successMessage = "APPROVED".equals(action) ? "결재가 승인되었습니다." : "결재가 반려되었습니다.";
                        return new ResponseEntity<>(
                                        Map.of("status", "success", "message", successMessage),
                                        HttpStatus.OK);
                } catch (IllegalArgumentException e) {
                        // 유효하지 않은 결재 요청 (예: 이미 승인/반려된 문서, 결재자가 아님 등)
                        return new ResponseEntity<>(
                                        Map.of("status", "error", "message", e.getMessage()),
                                        HttpStatus.BAD_REQUEST);
                } catch (Exception e) {
                        // 그 외 예상치 못한 서버 오류
                        return new ResponseEntity<>(
                                        Map.of("status", "error", "message", "서버 오류: " + e.getMessage()),
                                        HttpStatus.INTERNAL_SERVER_ERROR);
                }
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
