package com.flow.coretime.users.controller;

import com.flow.coretime.common.dto.ApiResponse;
import com.flow.coretime.users.model.SubstituteApprovalRequestDto;
import com.flow.coretime.users.model.SubstituteApprovalResponseDto;
import com.flow.coretime.users.model.User;
import com.flow.coretime.users.service.SubstituteApprovalService;
import com.flow.coretime.users.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/users/substitute-approvals")
public class SubstituteApprovalController {

    private final SubstituteApprovalService substituteApprovalService;
    private final UserService userService;

    @GetMapping
    public String getSubstituteApprovalPage(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        String userId = userDetails.getUsername();
        List<SubstituteApprovalResponseDto> substituteApprovals = substituteApprovalService
                .getSubstituteApprovals(userId);
        model.addAttribute("substituteApprovals", substituteApprovals);

        List<User> allUsers = userService.findAllUsers();
        model.addAttribute("allUsers", allUsers);

        return "user/substituteApproval";
    }

    @PostMapping
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> addSubstituteApproval(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody SubstituteApprovalRequestDto request) {
        substituteApprovalService.addSubstituteApproval(userDetails.getUsername(), request);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<ApiResponse<Void>> deleteSubstituteApproval(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable("id") Long id) {
        substituteApprovalService.deleteSubstituteApproval(id, userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
