package com.flow.coretime.elecApproval.controller;

import com.flow.coretime.common.dto.ApiResponse;
import com.flow.coretime.elecApproval.model.ApproverCandidateDto;
import com.flow.coretime.elecApproval.model.MyLineResponseDto;
import com.flow.coretime.elecApproval.model.MyLineSaveDto;
import com.flow.coretime.elecApproval.service.ElecApprovalCommandService;
import com.flow.coretime.elecApproval.service.ElecApprovalQueryService;
import com.flow.coretime.users.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/elecApproval")
public class ElecApprovalLineController {

    private final ElecApprovalQueryService elecApprovalQueryService;
    private final ElecApprovalCommandService elecApprovalCommandService;
    private final UserService userService;

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
}
