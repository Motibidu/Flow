package com.flow.coretime.notification;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.flow.coretime.notification.mapper.NotificationMapper;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
@Service
public class NotificationService {
    // 사용자 ID별로 SseEmitter를 저장 (동시성 고려)
    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();
    private final NotificationMapper notificationMapper;

    public SseEmitter subscribe(String userId) {
        // 만료 시간 1시간 설정
        SseEmitter emitter = new SseEmitter(60 * 60 * 1000L);

        emitters.put(userId, emitter);

        // 연결 종료/타임아웃 시 맵에서 제거
        emitter.onCompletion(() -> emitters.remove(userId));
        emitter.onTimeout(() -> emitters.remove(userId));
        emitter.onError((e) -> emitters.remove(userId));

        // 최초 연결 시 더미 데이터 전송 (503 에러 방지)
        try {
            emitter.send(SseEmitter.event()
                    .name("connect")
                    .data("connected!"));
        } catch (IOException e) {
            log.error("SSE 연결 알림 전송 실패", e);
        }

        return emitter;
    }

    public void send(int docId, String userId, String title, String message, String url) {

        // 1. DB에 먼저 저장 (영속성 확보)
        NotificationDTO notifcationDto = NotificationDTO.create(docId, userId, title, message, url);

        notificationMapper.insertNotification(notifcationDto);

        // 2. 접속 중인 경우 실시간 발송 (SSE)
        SseEmitter emitter = emitters.get(userId);
        if (emitter != null) {
            try {
                Map<String, String> data = new HashMap<>();
                data.put("docId", String.valueOf(docId));
                data.put("message", message);
                data.put("targetUrl", url);

                emitter.send(SseEmitter.event()
                        .name("notification")
                        .data(data, MediaType.APPLICATION_JSON));
            } catch (IOException e) {
                emitters.remove(userId);
                log.error("알림 전송 실패", e);
            }
        }
    }

    public List<NotificationDTO> selectRecentNotifications(String userId) {
        return notificationMapper.selectRecentNotifications(userId);

    }

    public void markAsRead(int notifId) {
        notificationMapper.markAsRead((long) notifId);
    }

    public void markAllAsRead(String userId) {
        notificationMapper.markAllAsRead(userId);
    }

    public PageInfo<NotificationDTO> selectAllNotifications(String userId, int page, int size) {
        PageHelper.startPage(page, size);
        List<NotificationDTO> list = notificationMapper.selectAllNotifications(userId);
        return new PageInfo<>(list); // 여기에 전체 개수, 페이지 수 등이 다 들어있습니다.
    }
}
