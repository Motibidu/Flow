-- 모델 구조에 맞게 테이블 생성
CREATE TABLE APPROVAL_LINE_CONFIG (
    CONFIG_ID INT AUTO_INCREMENT PRIMARY KEY,
    DOC_TYPE VARCHAR(50) NOT NULL,          -- Enum (VACATION_REQUEST 등)
    TARGET_RANK VARCHAR(50) NOT NULL,       -- 직급 (팀장, 본부장 등)
    DEPT_TYPE VARCHAR(50) NOT NULL,         -- 부서기준 (MY_DEPT 등)
    STEP_ORDER INT NOT NULL,                -- 순서
    DESCRIPTION VARCHAR(255),               -- 설명
    CREATED_AT DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- 휴가신청서 고정 결재선 설정
INSERT INTO APPROVAL_LINE_CONFIG (DOC_TYPE, TARGET_RANK, DEPT_TYPE, STEP_ORDER, DESCRIPTION)
VALUES 
('VACATION_REQUEST', '팀장', 'MY_DEPT', 1, '1차 결재: 팀장'),
('VACATION_REQUEST', '본부장', 'MY_DEPT', 2, '2차 결재: 본부장'),
('VACATION_REQUEST', '대표이사', 'HR_DEPT', 3, '최종 승인: 대표이사');


-- 비밀번호는 편의상 '1234'로 통일했습니다 (BCrypt 암호화 사용 시 해당 해시값 필요)
