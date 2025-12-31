package com.flow.coretime.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

        @Override
        public void configureMessageBroker(MessageBrokerRegistry config) {
                // 메시지를 구독(수신)하는 경로의 접두사입니다.
                config.enableSimpleBroker("/topic", "/queue");
                // 메시지를 보낼 때 사용하는 경로의 접두사입니다.
                config.setApplicationDestinationPrefixes("/app");
                config.setUserDestinationPrefix("/user");
        }

        @Override
        public void registerStompEndpoints(StompEndpointRegistry registry) {
                // 클라이언트가 연결할 웹소켓 엔드포인트를 설정합니다.
                registry.addEndpoint("/ws-stomp")
                                .withSockJS(); // 아까 오타 수정했던 SockJS를 사용합니다!
        }
}
