package com.flow.coretime.notification;

import java.util.List;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

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
        public ResponseEntity<List<NotificationDTO>> selectRecentNotifications(
                        @RequestParam(name = "userId") String userId) {
                List<NotificationDTO> recentNotifications = notificationService.selectRecentNotifications(userId);
                return ResponseEntity.ok(recentNotifications);
        }

        @GetMapping("/api/notifications/all-notifications")
        public ResponseEntity<PageInfo<NotificationDTO>> selectallNotifications(
                        @RequestParam(name = "userId") String userId,
                        @RequestParam(name = "page", defaultValue = "1") int page,
                        @RequestParam(name = "size", defaultValue = "10") int size) {

                // List 대신 PageInfo를 반환합니다.
                PageInfo<NotificationDTO> pageInfo = notificationService.selectAllNotifications(userId, page, size);
                return ResponseEntity.ok(pageInfo);
        }

        @GetMapping("/api/notifications/all")
        public String viewAllNotifications(@AuthenticationPrincipal UserDetails userDetails, Model model) {
                String currentUserId = userDetails.getUsername();
                model.addAttribute("currentUserId", currentUserId);

                return "notifications/allNotifications";
        }

        @PostMapping("/api/notifications/mark-read")
        public ResponseEntity<String> markAsRead(@RequestParam("notifId") int notifId) {
                notificationService.markAsRead(notifId);
                return ResponseEntity.ok("success");
        }

        @PostMapping("/api/notifications/mark-all-read")
        public ResponseEntity<String> markAllAsRead(@RequestParam("userId") String userId) {
                notificationService.markAllAsRead(userId);
                return ResponseEntity.ok("success");
        }
}
