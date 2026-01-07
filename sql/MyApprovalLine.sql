-- 1. 나의 결재선 (마스터 테이블)
CREATE TABLE my_approval_line (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '결재선 고유 ID',
    user_id     VARCHAR(50) NOT NULL COMMENT '소유자 ID',
    title       VARCHAR(100) NOT NULL COMMENT '결재선 제목',
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 결재선 상세 (디테일 테이블)
CREATE TABLE my_approval_line_detail (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '상세 고유 ID',
    line_id     BIGINT NOT NULL COMMENT '마스터 테이블 ID (FK)',
    approver_id VARCHAR(50) NOT NULL COMMENT '결재자 ID',
    seq         INT NOT NULL COMMENT '결재 순서',
    
    CONSTRAINT fk_my_approval_line 
        FOREIGN KEY (line_id) REFERENCES my_approval_line (id) 
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;