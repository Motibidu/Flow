package com.flow.coretime.elecApproval.controller;

import com.flow.coretime.common.dto.ApiResponse;
import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.mapper.ElecApprovalLineConfigMapper;
import com.flow.coretime.elecApproval.model.*;
import com.flow.coretime.elecApproval.service.AttachmentService;
import com.flow.coretime.elecApproval.service.ElecApprovalCommandService;
import com.flow.coretime.elecApproval.service.ElecApprovalQueryService;
import com.flow.coretime.users.model.User;
import com.flow.coretime.users.service.UserService;
import com.github.pagehelper.PageInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriUtils;

import java.net.MalformedURLException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/elecApproval")
public class ElecApprovalController {

        @Value("${upload.dir}")
        private String uploadDir;

        private final ElecApprovalLineConfigMapper elecApprovalLineConfigMapper;
        private final ElecApprovalCommandService elecApprovalCommandService;
        private final ElecApprovalQueryService elecApprovalQueryService;
        private final AttachmentService attachmentService;
        private final UserService userService;

        @PreAuthorize("isAuthenticated()")
        @GetMapping
        public String showDashboard(@AuthenticationPrincipal UserDetails userDetails, Model model) {
                PageInfo<DocumentRespDto> myTurn = elecApprovalQueryService
                                .findMyTurn(userDetails.getUsername(), 1, 5, null, null);
                model.addAttribute("myTurn", myTurn);

                PageInfo<DocumentRespDto> pendingOrInProgress = elecApprovalQueryService
                                .findPendingOrInProgress(userDetails.getUsername(), 1, 5, null, null);
                log.info("pendingOrInProgress: {}", pendingOrInProgress);
                model.addAttribute("pendingOrInProgress", pendingOrInProgress);

                PageInfo<DocumentRespDto> rejectedOrRecalled = elecApprovalQueryService
                                .findRejectedOrRecalled(userDetails.getUsername(), 1, 5, null, null);
                model.addAttribute("rejectedOrRecalled", rejectedOrRecalled);

                PageInfo<DocumentRespDto> approved = elecApprovalQueryService
                                .findApproved(userDetails.getUsername(), 1, 5, null, null);
                model.addAttribute("approved", approved);

                return "elecApproval/elecApproval";
        }

        // 전자결재 작성 페이지
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/documents")
        public String showDocumentForm(@RequestParam("formType") String formType,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {
                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUserName", currentUser.getName());
                model.addAttribute("currentUserDepartment", currentUser.getDepartment().getDisplayName());

                if (DocumentType.VACATION_REQUEST.toString().equals(formType)) {
                        List<ApprovalLineConfigRespDto> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalLineConfigRespDto(currentUser.getId(), currentUser.getDepartment(),
                                                        DocumentType.VACATION_REQUEST);
                        log.info("approvalLines: {}", approvalLines);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/vacationRequestForm";
                } else if (DocumentType.EXPENSE_REPORT.toString().equals(formType)) {
                        List<ApprovalLineConfigRespDto> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalLineConfigRespDto(currentUser.getId(), currentUser.getDepartment(),
                                                        DocumentType.EXPENSE_REPORT);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/expenseReportForm";
                } else if (DocumentType.GENERAL_PROPOSAL.toString().equals(formType)) {
                        List<ApprovalLineConfigRespDto> approvalLines = elecApprovalLineConfigMapper
                                        .getApprovalLineConfigRespDto(currentUser.getId(), currentUser.getDepartment(),
                                                        DocumentType.GENERAL_PROPOSAL);
                        model.addAttribute("approvalLines", approvalLines);

                        return "elecApproval/generalProposalForm";
                }

                return "elecApproval/elecApprovalNew";

        }

        // 전자결재 제출
        @ResponseBody
        @PreAuthorize("isAuthenticated()")
        @PostMapping("/documents")
        public ResponseEntity<ApiResponse<Void>> saveDocument(
                        @ModelAttribute DocumentReqDto request,
                        @RequestParam(value = "files", required = false) List<MultipartFile> files,
                        @AuthenticationPrincipal UserDetails userDetails) {

                log.info("request: {}", request);
                log.info("files: {}", files != null ? files.size() : 0);

                elecApprovalCommandService.saveDocumentAndInitialApproval(request, files, userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("성공적으로 생성되었습니다."));
        }

        // 전자결재 임시저장/재상신 페이지
        @PreAuthorize("@documentChecker.isViewer(#p0, principal.username)")
        @GetMapping("/documents/{docId}")
        public String showEditForm(@PathVariable("docId") int docId, Model model) {
                DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
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

        // 전자결재 임시저장/상신취소-> 상신
        @ResponseBody
        @PreAuthorize("@documentChecker.isInitiator(#p0, principal.username)")
        @PostMapping("/documents/{docId}")
        public ResponseEntity<ApiResponse<String>> redraftDocument(
                        @PathVariable("docId") int docId,
                        @ModelAttribute DocumentReqDto request,
                        @RequestParam(value = "files", required = false) List<MultipartFile> files,
                        @RequestParam(value = "deleteFileIds", required = false) List<Long> deleteFileIds,
                        @AuthenticationPrincipal UserDetails userDetails) {
                log.info("docId: {}", docId);
                log.info("request: {}", request);
                elecApprovalCommandService.redraftDocument(docId, request, files, deleteFileIds);

                return ResponseEntity.ok(ApiResponse.success("/elecApproval/detail/" + docId));
        }

        // 전자결재 임시저장
        @ResponseBody
        @PreAuthorize("isAuthenticated()")
        @PostMapping("/documents/temp")
        public ResponseEntity<ApiResponse<Void>> saveTempDocument(
                        @ModelAttribute DocumentReqDto request,
                        @RequestParam(value = "files", required = false) List<MultipartFile> files,
                        @AuthenticationPrincipal UserDetails userDetails) {

                log.info("request: {}", request);
                log.info("files: {}", files != null ? files.size() : 0);
                elecApprovalCommandService.saveTempDocument(request, files, userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("성공적으로 생성되었습니다."));
        }

        // 전자결재 임시저장 수정
        @ResponseBody
        @PreAuthorize("@documentChecker.isInitiator(#p0, principal.username)")
        @PostMapping("/documents/temp/{docId}")
        public ResponseEntity<ApiResponse<Void>> updateTempDocument(
                        @ModelAttribute DocumentReqDto request,
                        @PathVariable("docId") int docId,
                        @RequestParam(value = "files", required = false) List<MultipartFile> files,
                        @RequestParam(value = "deleteFileIds", required = false) List<Long> deleteFileIds,
                        @AuthenticationPrincipal UserDetails userDetails) {

                log.info("request: {}", request);
                log.info("files: {}", files != null ? files.size() : 0);
                log.info("deleteFileIds: {}", deleteFileIds != null ? deleteFileIds.size() : 0);
                log.info("docId: {}", docId);

                elecApprovalCommandService.updateTempDocument(docId, request, files, deleteFileIds,
                                userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("성공적으로 생성되었습니다."));
        }

        // 전자결재 상세 페이지
        @PreAuthorize("@documentChecker.isViewer(#p0, principal.username)")
        @GetMapping("/detail/{docId}")
        public String detailDocument(@PathVariable("docId") int docId,
                        @AuthenticationPrincipal UserDetails userDetails, Model model) {

                DocumentRespDto document = elecApprovalQueryService.getDocumentById(docId);
                model.addAttribute("document", document);

                User currentUser = userService.findById(userDetails.getUsername()).orElseThrow(
                                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
                model.addAttribute("currentUser", currentUser);

                log.info("document: {}", document);
                log.info("currentUser: {}", currentUser);

                if (DocumentType.VACATION_REQUEST.equals(document.getDocType())) {
                        return "elecApproval/vacationRequestDetail";
                } else if (DocumentType.EXPENSE_REPORT.equals(document.getDocType())) {
                        return "elecApproval/expenseReportDetail";
                } else if (DocumentType.GENERAL_PROPOSAL.equals(document.getDocType())) {
                        return "elecApproval/generalProposalDetail";
                }

                return "vacationRequestDetail";
        }

        @ResponseBody
        @PreAuthorize("@documentChecker.isCurrentApprover(#p0, principal.username)")
        @PostMapping("/approve/{docId}")
        public ResponseEntity<ApiResponse<Void>> approveDocument(
                        @PathVariable("docId") int docId,
                        @RequestBody ApprovalCommentDto approvalCommentDto,
                        @AuthenticationPrincipal UserDetails userDetails) {

                elecApprovalCommandService.approveApproval(docId, approvalCommentDto.comment(), userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("결재가 승인되었습니다."));
        }

        @ResponseBody
        @PreAuthorize("@documentChecker.isCurrentApprover(#p0, principal.username)")
        @PostMapping("/reject/{docId}")
        public ResponseEntity<ApiResponse<Void>> rejectDocument(
                        @PathVariable("docId") int docId,
                        @RequestBody ApprovalCommentDto approvalCommentDto,
                        @AuthenticationPrincipal UserDetails userDetails) {

                elecApprovalCommandService.rejectApproval(docId, approvalCommentDto.comment(), userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("결재가 반려되었습니다."));
        }

        @ResponseBody
        @PreAuthorize("isAuthenticated()")
        @PostMapping("/substitute-approve/{docId}")
        public ResponseEntity<ApiResponse<Void>> substituteApproveDocument(
                @PathVariable("docId") int docId,
                @RequestBody ApprovalCommentDto approvalCommentDto,
                @AuthenticationPrincipal UserDetails userDetails) {

                elecApprovalCommandService.substituteApproveApproval(docId, approvalCommentDto.comment(), userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("대리 결재가 승인되었습니다."));
        }

        @ResponseBody
        @PreAuthorize("isAuthenticated()")
        @PostMapping("/substitute-reject/{docId}")
        public ResponseEntity<ApiResponse<Void>> substituteRejectDocument(
                @PathVariable("docId") int docId,
                @RequestBody ApprovalCommentDto approvalCommentDto,
                @AuthenticationPrincipal UserDetails userDetails) {

                elecApprovalCommandService.substituteRejectApproval(docId, approvalCommentDto.comment(), userDetails.getUsername());

                return ResponseEntity.ok(ApiResponse.success("대리 결재가 반려되었습니다."));
        }

        // 상신 취소하기
        @PreAuthorize("@documentChecker.isInitiator(#p0, principal.username)")
        @PostMapping("/recall/{docId}")
        @ResponseBody
        public ResponseEntity<ApiResponse<Void>> recall(@PathVariable(name = "docId") int docId,
                        @AuthenticationPrincipal UserDetails userDetails) {
                elecApprovalCommandService.recallDocument(docId, userDetails.getUsername());
                return ResponseEntity.ok(ApiResponse.success("상신 취소가 성공적으로 완료되었습니다."));
        }

        // 문서 삭제하기
        @PreAuthorize("@documentChecker.isInitiator(#p0, principal.username)")
        @DeleteMapping("/delete/{docId}")
        public ResponseEntity<ApiResponse<Void>> deleteDocument(
                        @PathVariable(name = "docId") int docId,
                        @AuthenticationPrincipal UserDetails userDetails) {
                elecApprovalCommandService.deleteDocument(docId);
                return ResponseEntity.ok(ApiResponse.success("문서가 성공적으로 삭제되었습니다."));
        }

        // 내가 저장한 결재선 불러오기
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/my-lines")
        public ResponseEntity<ApiResponse<List<MyLineResponseDto>>> findMyApprovalLines(
                        @AuthenticationPrincipal UserDetails userDetails) {

                String userId = userDetails.getUsername();
                List<MyLineResponseDto> myLines = elecApprovalQueryService.findMyApprovalLines(userId);

                return ResponseEntity.ok(ApiResponse.success(myLines));

        }

        // "내가 저장한 결재선"에 저장
        @PreAuthorize("isAuthenticated()")
        @PostMapping("/my-lines")
        public ResponseEntity<ApiResponse<Void>> saveMyLine(
                        @RequestBody MyLineSaveDto myLineSaveDto,
                        @AuthenticationPrincipal UserDetails userDetails) {
                String userId = userDetails.getUsername();
                elecApprovalCommandService.saveMyApprovalLine(userId, myLineSaveDto);
                return ResponseEntity.ok(ApiResponse.success("성공적으로 저장되었습니다."));
        }

        // 내가 저장한 결재선 삭제
        @PreAuthorize("isAuthenticated()")
        @DeleteMapping("/my-lines/{lineId}")
        @ResponseBody
        public ResponseEntity<ApiResponse<Void>> deleteMyLine(
                        @PathVariable("lineId") int lineId,
                        @AuthenticationPrincipal UserDetails userDetails) {
                String userId = userDetails.getUsername();
                elecApprovalCommandService.deleteMyApprovalLine(userId, lineId);
                return ResponseEntity.ok(ApiResponse.success("성공적으로 삭제되었습니다."));
        }

        // 결재선 지정 리스트
        @PreAuthorize("isAuthenticated()")
        @ResponseBody
        @GetMapping("/approver-candidates")
        public ResponseEntity<ApiResponse<List<ApproverCandidateDto>>> getAllApproverCandidates() {
                List<ApproverCandidateDto> approverCandidates = userService.getAllApproverCandidates();
                return ResponseEntity.ok(ApiResponse.success(approverCandidates));
        }

        // 첨부파일 다운로드
        @PreAuthorize("@documentChecker.canDownloadFile(#p0, principal.username)")
        @GetMapping("/download/{fileId}")
        public ResponseEntity<Resource> downloadFile(@PathVariable(name = "fileId") Long fileId)
                        throws MalformedURLException {
                AttachmentEntity fileInfo = attachmentService.getAttachment(fileId);

                Path filePath = Paths.get(uploadDir + "/" + fileInfo.getSavedName());
                Resource resource = new UrlResource(filePath.toUri());
                String encodedUploadFileName = UriUtils.encode(fileInfo.getOriginName(), StandardCharsets.UTF_8);
                String contentDisposition = "attachment; filename=\"" + encodedUploadFileName + "\"";

                return ResponseEntity.ok()
                                .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition)
                                .body(resource);
        }

        // 임시저장 리스트
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/temp")
        public String tempList(Model model, @AuthenticationPrincipal UserDetails userDetails,
                        @RequestParam(value = "searchType", required = false) String searchType,
                        @RequestParam(value = "keyword", required = false) String keyword,
                        @RequestParam(value = "page", defaultValue = "1") int page,
                        @RequestParam(value = "size", defaultValue = "15") int size) {
                PageInfo<DocumentRespDto> pageInfo = elecApprovalQueryService.findAllTemp(userDetails.getUsername(),
                                page,
                                size, searchType, keyword);
                model.addAttribute("docList", pageInfo.getList());
                model.addAttribute("pageInfo", pageInfo);
                return "elecApproval/tempList";
        }

        // 결재 차례 문서 리스트
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/my-turn")
        public String myTurnList(Model model, @AuthenticationPrincipal UserDetails userDetails,
                        @RequestParam(value = "searchType", required = false) String searchType,
                        @RequestParam(value = "keyword", required = false) String keyword,
                        @RequestParam(value = "page", defaultValue = "1") int page,
                        @RequestParam(value = "size", defaultValue = "15") int size) {
                PageInfo<DocumentRespDto> pageInfo = elecApprovalQueryService.findMyTurn(userDetails.getUsername(),
                                page,
                                size, searchType, keyword);
                model.addAttribute("docList", pageInfo.getList());
                model.addAttribute("pageInfo", pageInfo);
                return "elecApproval/myTurnList";
        }

        // 진행중인 문서 리스트
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/pending-or-progress")
        public String pendingOrProgressList(Model model, @AuthenticationPrincipal UserDetails userDetails,
                        @RequestParam(value = "searchType", required = false) String searchType,
                        @RequestParam(value = "keyword", required = false) String keyword,
                        @RequestParam(value = "page", defaultValue = "1") int page,
                        @RequestParam(value = "size", defaultValue = "15") int size) {

                log.info("searchType: {}", searchType);
                log.info("keyword: {}", keyword);
                PageInfo<DocumentRespDto> pageInfo = elecApprovalQueryService
                                .findPendingOrInProgress(userDetails.getUsername(), page, size, searchType, keyword);
                // log.info("pageInfo: {}", pageInfo);
                model.addAttribute("docList", pageInfo.getList());
                model.addAttribute("pageInfo", pageInfo);
                return "elecApproval/pendingOrProgressList";
        }

        // 반려 및 취소한 문서 리스트
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/rejected-or-recalled")
        public String rejectedOrRecalledList(Model model, @AuthenticationPrincipal UserDetails userDetails,
                        @RequestParam(value = "searchType", required = false) String searchType,
                        @RequestParam(value = "keyword", required = false) String keyword,
                        @RequestParam(value = "page", defaultValue = "1") int page,
                        @RequestParam(value = "size", defaultValue = "15") int size) {
                PageInfo<DocumentRespDto> pageInfo = elecApprovalQueryService
                                .findRejectedOrRecalled(userDetails.getUsername(), page, size, searchType, keyword);
                model.addAttribute("docList", pageInfo.getList());
                model.addAttribute("pageInfo", pageInfo);
                return "elecApproval/rejectedOrRecalledList";
        }

        // 승인된 문서 리스트
        @PreAuthorize("isAuthenticated()")
        @GetMapping("/approved")
        public String approvedList(Model model, @AuthenticationPrincipal UserDetails userDetails,
                        @RequestParam(value = "searchType", required = false) String searchType,
                        @RequestParam(value = "keyword", required = false) String keyword,
                        @RequestParam(value = "page", defaultValue = "1") int page,
                        @RequestParam(value = "size", defaultValue = "15") int size) {
                PageInfo<DocumentRespDto> pageInfo = elecApprovalQueryService.findApproved(userDetails.getUsername(),
                                page,
                                size, searchType, keyword);
                model.addAttribute("docList", pageInfo.getList());
                model.addAttribute("pageInfo", pageInfo);
                return "elecApproval/approvedList";
        }

}