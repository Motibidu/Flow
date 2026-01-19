-- APPROVAL_HISTORY 테이블에 대리 결재자 ID를 위한 컬럼 추가
ALTER TABLE APPROVAL_HISTORY
ADD COLUMN acting_approver_id VARCHAR(50) NULL COMMENT '대리 결재를 수행한 사용자 ID',
ADD CONSTRAINT fk_acting_approver
FOREIGN KEY (acting_approver_id) REFERENCES USERS(id);
