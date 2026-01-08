package com.flow.coretime.elecApproval.controller;

import java.util.ArrayList;
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
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.flow.coretime.common.dto.ApiResponse;
import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.mapper.ElecApprovalLineConfigMapper;
import com.flow.coretime.elecApproval.model.ApprovalLineConfigRespDto;
import com.flow.coretime.elecApproval.model.ApprovalReq;
import com.flow.coretime.elecApproval.model.ApproverCandidateDto;
import com.flow.coretime.elecApproval.model.Document;
import com.flow.coretime.elecApproval.model.DocumentReqDto;
import com.flow.coretime.elecApproval.model.ElecApprovalHistory;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfigEntity;
import com.flow.coretime.elecApproval.model.MyApprovalLineEntity;
import com.flow.coretime.elecApproval.model.MyLineResponseDto;
import com.flow.coretime.elecApproval.model.MyLineSaveDto;
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

                return "elecApproval/elecApproval";
        }

        @GetMapping("/new")
        public String showElecApprovalNew(@RequestParam("formType") String formType,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {
                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUserName", currentUser.getName());
                model.addAttribute("currentUserDepartment", currentUser.getDepartment().getDisplayName());

                if (DocumentType.VACATION_REQUEST.toString().equals(formType)) {
                        List<ApprovalLineConfigRespDto> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalLineConfigRespDto(currentUser.getDepartment(),
                                                        DocumentType.VACATION_REQUEST);
                        log.info("approvalLines: {}", approvalLines);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/vacationRequestForm";
                } else if (DocumentType.EXPENSE_REPORT.toString().equals(formType)) {
                        List<ElecApprovalLineConfigEntity> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalConfigList(DocumentType.EXPENSE_REPORT);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/expenseReportForm";
                } else if (DocumentType.GENERAL_PROPOSAL.toString().equals(formType)) {
                        List<ElecApprovalLineConfigEntity> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalConfigList(DocumentType.GENERAL_PROPOSAL);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/generalProposalForm";
                }

                return "elecApproval/elecApprovalNew";

        }

        @GetMapping("/approver-candidates")
        @ResponseBody
        public List<ApproverCandidateDto> getAllApproverCandidates() {
                List<ApproverCandidateDto> approverCandidates = userService.getAllApproverCandidates();
                log.info("approverCandidates: {}", approverCandidates);

                return approverCandidates;

        }

        @PostMapping("/documents")
        @ResponseBody
        public ResponseEntity<ApiResponse<Void>> createDocument(
                        @ModelAttribute DocumentReqDto request,
                        @RequestParam(value = "files", required = false) List<MultipartFile> files,
                        @AuthenticationPrincipal UserDetails userDetails) {

                log.info("request: {}", request);
                log.info("files: {}", files != null ? files.size() : 0);

                elecApprovalService.createDocumentAndInitialApproval(request, files, userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("성공적으로 생성되었습니다."));
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
        @ResponseBody
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

        // 상신취소
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

        // 내가 저장한 결재선 조회
        @GetMapping("/my-lines")
        public ResponseEntity<ApiResponse<List<MyLineResponseDto>>> findMyApprovalLines(
                        @AuthenticationPrincipal UserDetails userDetails) {

                String userId = userDetails.getUsername();
                List<MyLineResponseDto> myLines = elecApprovalService.findMyApprovalLines(userId);

                return ResponseEntity.ok(ApiResponse.success(myLines));

        }

        // 내가 저장한 결재선 저장
        @PostMapping("/my-lines")
        public ResponseEntity<ApiResponse<Void>> saveMyLine(
                        @RequestBody MyLineSaveDto myLineSaveDto,
                        @AuthenticationPrincipal UserDetails userDetails) {
                String userId = userDetails.getUsername();
                elecApprovalService.saveMyApprovalLine(userId, myLineSaveDto);
                return ResponseEntity.ok(ApiResponse.success("성공적으로 저장되었습니다."));
        }

        // 내가 저장한 결재선 삭제
        @DeleteMapping("/my-lines/{lineId}")
        @ResponseBody
        public ResponseEntity<ApiResponse<Void>> deleteMyLine(
                        @PathVariable("lineId") int lineId,
                        @AuthenticationPrincipal UserDetails userDetails) {
                String userId = userDetails.getUsername();
                elecApprovalService.deleteMyApprovalLine(userId, lineId);
                return ResponseEntity.ok(ApiResponse.success("성공적으로 삭제되었습니다."));
        }

}
