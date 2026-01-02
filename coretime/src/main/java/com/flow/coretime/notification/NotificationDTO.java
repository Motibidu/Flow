package com.flow.coretime.notification;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationDTO {
        private Long notifId; // 알림 고유 번호 (PK)
        private String recipientId; // 수신자 아이디
        private String title;
        private String message; // 알림 메시지 내용
        private String targetUrl; // 알림 클릭 시 이동할 페이지 경로
        private ReadStatus isRead; // 읽음 여부
        @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
        private LocalDateTime createdAt; // 알림 생성 시간

        public static NotificationDTO create(String recipientId, String title, String message, String targetUrl) {
                return NotificationDTO.builder()
                                .recipientId(recipientId)
                                .title(title)
                                .message(message)
                                .targetUrl(targetUrl)
                                .isRead(ReadStatus.UNREAD)
                                .createdAt(LocalDateTime.now())
                                .build();
        }
}
