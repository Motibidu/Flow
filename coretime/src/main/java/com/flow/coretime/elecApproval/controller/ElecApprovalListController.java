package com.flow.coretime.elecApproval.controller;

import com.flow.coretime.elecApproval.model.DocumentRespDto;
import com.flow.coretime.elecApproval.service.ElecApprovalQueryService;
import com.github.pagehelper.PageInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Slf4j
@RequiredArgsConstructor
@Controller
@RequestMapping("/elecApproval")
public class ElecApprovalListController {

    private final ElecApprovalQueryService elecApprovalQueryService;

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
