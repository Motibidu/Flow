package com.flow.coretime.notification;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ReadStatus {
    READ("읽음"),
    UNREAD("안 읽음");

    private final String displayName;
}
