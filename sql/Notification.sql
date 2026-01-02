CREATE TABLE notifications (
    notif_id      INT AUTO_INCREMENT PRIMARY KEY,
    recipient_id  VARCHAR(50) NOT NULL,        -- 수신자 ID (사원번호 등)
    title         VARCHAR(100) NOT NULL,       -- 알림 제목
    message       VARCHAR(500) NOT NULL,       -- 알림 내용 (예: "신규 연차 신청서가 접수되었습니다.")
    target_url    VARCHAR(255),                -- 클릭 시 이동할 상세 페이지 URL
    is_read       VARCHAR(10) DEFAULT 'UNREAD' NOT NULL, 
    
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_recipient_read (recipient_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;