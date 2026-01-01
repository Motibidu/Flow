package com.flow.coretime.notification;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;

@RestController
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
}
