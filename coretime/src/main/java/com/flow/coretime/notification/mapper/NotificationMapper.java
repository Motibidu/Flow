package com.flow.coretime.notification.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.flow.coretime.notification.NotificationDTO;

@Mapper
public interface NotificationMapper {
    // 알림 저장
    void insertNotification(NotificationDTO notification);

    // 읽지 않은 알림 목록 조회
    List<NotificationDTO> selectUnreadList(String userId);

    // 알림 읽음 처리
    void updateReadStatus(Long notifId);
}
