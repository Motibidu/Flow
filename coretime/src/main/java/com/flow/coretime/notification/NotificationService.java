package com.flow.coretime.notification;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class NotificationService {
    // 사용자 ID별로 SseEmitter를 저장 (동시성 고려)
    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();

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

    public void send(String userId, Object data) {
        SseEmitter emitter = emitters.get(userId);
        if (emitter != null) {
            try {
                emitter.send(SseEmitter.event()
                        .name("notification")
                        .data("한글 테스트 메시지"));
            } catch (IOException e) {
                emitters.remove(userId);
                log.error("알림 전송 실패", e);
            }
        }
    }
}
