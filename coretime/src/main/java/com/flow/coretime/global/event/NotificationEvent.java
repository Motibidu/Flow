package com.flow.coretime.global.event;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

@Getter
public class NotificationEvent extends ApplicationEvent {

    private final String userId;
    private final String title;
    private final String message;
    private final String link;

    public NotificationEvent(Object source, String userId, String title, String message, String link) {
        super(source);
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.link = link;
    }
}
