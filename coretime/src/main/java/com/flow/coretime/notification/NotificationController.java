package com.flow.coretime.notification;

import java.util.List;

import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.flow.coretime.common.dto.ApiResponse;
import com.github.pagehelper.PageInfo;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class NotificationController {
        private final NotificationService notificationService;

        @GetMapping(value = "/api/notifications/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
        public SseEmitter subscribe(@RequestParam("userId") String userId, HttpServletResponse response) {

                // 1. 응답 헤더 강제 설정
                response.setCharacterEncoding("UTF-8");
                response.setHeader("Content-Type", "text/event-stream;charset=UTF-8");
                return notificationService.subscribe(userId);
        }

        @GetMapping("/api/notifications/recent-notifications")
        @ResponseBody
        public ApiResponse<List<NotificationDTO>> selectRecentNotifications(
                        @RequestParam(name = "userId") String userId) {
                List<NotificationDTO> recentNotifications = notificationService.selectRecentNotifications(userId);
                return ApiResponse.success(recentNotifications);
        }

        @GetMapping("/api/notifications/all-notifications")
        @ResponseBody
        public ApiResponse<PageInfo<NotificationDTO>> selectallNotifications(
                        @RequestParam(name = "userId") String userId,
                        @RequestParam(name = "page", defaultValue = "1") int page,
                        @RequestParam(name = "size", defaultValue = "10") int size) {

                PageInfo<NotificationDTO> pageInfo = notificationService.selectAllNotifications(userId, page, size);
                return ApiResponse.success(pageInfo);
        }

        @GetMapping("/api/notifications/all")
        public String viewAllNotifications(@AuthenticationPrincipal UserDetails userDetails, Model model) {
                String currentUserId = userDetails.getUsername();
                model.addAttribute("currentUserId", currentUserId);

                return "notifications/allNotifications";
        }

        @PostMapping("/api/notifications/mark-read")
        @ResponseBody
        public ApiResponse<String> markAsRead(@RequestParam("notifId") int notifId) {
                notificationService.markAsRead(notifId);
                return ApiResponse.success("success");
        }

        @PostMapping("/api/notifications/mark-all-read")
        @ResponseBody
        public ApiResponse<String> markAllAsRead(@RequestParam("userId") String userId) {
                notificationService.markAllAsRead(userId);
                return ApiResponse.success("success");
        }
}

