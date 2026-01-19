CREATE TABLE SUBSTITUTE_APPROVAL (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    delegator_id VARCHAR(50) NOT NULL COMMENT '권한을 위임한 사용자 ID',
    substitute_id VARCHAR(50) NOT NULL COMMENT '권한을 위임받은 사용자 ID',
    start_date DATE NOT NULL COMMENT '대리 결재 시작일',
    end_date DATE NOT NULL COMMENT '대리 결재 종료일',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delegator FOREIGN KEY (delegator_id) REFERENCES USERS(id),
    CONSTRAINT fk_substitute FOREIGN KEY (substitute_id) REFERENCES USERS(id)
) COMMENT '대리 결재 설정';
