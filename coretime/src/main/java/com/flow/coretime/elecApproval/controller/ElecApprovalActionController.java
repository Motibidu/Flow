package com.flow.coretime.elecApproval.controller;

import com.flow.coretime.common.dto.ApiResponse;
import com.flow.coretime.elecApproval.model.ApprovalCommentDto;
import com.flow.coretime.elecApproval.service.ElecApprovalCommandService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RequiredArgsConstructor
@RestController
@RequestMapping("/elecApproval")
public class ElecApprovalActionController {

    private final ElecApprovalCommandService elecApprovalCommandService;

    @PreAuthorize("@documentChecker.isCurrentApprover(#p0, principal.username)")
    @PostMapping("/approve/{docId}")
    public ResponseEntity<ApiResponse<Void>> approveDocument(
            @PathVariable("docId") int docId,
            @RequestBody ApprovalCommentDto approvalCommentDto,
            @AuthenticationPrincipal UserDetails userDetails) {

        elecApprovalCommandService.approveDocument(docId, approvalCommentDto.comment());

        return ResponseEntity.ok(ApiResponse.success("결재가 승인되었습니다."));
    }

    @PreAuthorize("@documentChecker.isCurrentApprover(#p0, principal.username)")
    @PostMapping("/reject/{docId}")
    public ResponseEntity<ApiResponse<Void>> rejectDocument(
            @PathVariable("docId") int docId,
            @RequestBody ApprovalCommentDto approvalCommentDto,
            @AuthenticationPrincipal UserDetails userDetails) {

        elecApprovalCommandService.rejectApproval(docId, approvalCommentDto.comment(), userDetails.getUsername());

        return ResponseEntity.ok(ApiResponse.success("결재가 반려되었습니다."));
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/substitute-approve/{docId}")
    public ResponseEntity<ApiResponse<Void>> substituteApproveDocument(
            @PathVariable("docId") int docId,
            @RequestBody ApprovalCommentDto approvalCommentDto,
            @AuthenticationPrincipal UserDetails userDetails) {

        elecApprovalCommandService.substituteApprove(docId, approvalCommentDto.comment(),
                userDetails.getUsername());

        return ResponseEntity.ok(ApiResponse.success("대리 결재가 승인되었습니다."));
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/substitute-reject/{docId}")
    public ResponseEntity<ApiResponse<Void>> substituteRejectDocument(
            @PathVariable("docId") int docId,
            @RequestBody ApprovalCommentDto approvalCommentDto,
            @AuthenticationPrincipal UserDetails userDetails) {

        elecApprovalCommandService.substituteRejectApproval(docId, approvalCommentDto.comment(),
                userDetails.getUsername());

        return ResponseEntity.ok(ApiResponse.success("대리 결재가 반려되었습니다."));
    }
}
