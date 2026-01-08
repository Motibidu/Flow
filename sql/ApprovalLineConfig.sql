-- 모델 구조에 맞게 테이블 생성
CREATE TABLE APPROVAL_LINE_CONFIG (
    config_id INT AUTO_INCREMENT PRIMARY KEY,
    doc_type VARCHAR(50) NOT NULL,          -- Enum (VACATION_REQUEST 등)
    position VARCHAR(50) NOT NULL,       -- 직급 (팀장, 본부장 등)
    department VARCHAR(50) NOT NULL,         -- 부서기준 (MY_DEPT 등)
    approval_order INT NOT NULL,                -- 순서
    description VARCHAR(255),               -- 설명
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

  


-- 휴가신청서 고정 결재선 설정
INSERT INTO APPROVAL_LINE_CONFIG (DOC_TYPE, POSITION, DEPARTMENT, APPROVAL_ORDER, DESCRIPTION)
VALUES 
('VACATION_REQUEST', 'TEAM_LEADER', 'DEV', 1, '1차 결재: 팀장');

INSERT INTO APPROVAL_LINE_CONFIG 
(doc_type, position, department, approval_order, description, created_at)
VALUES 
('GENERAL_PROPOSAL', 'TEAM_LEADER', 'DFRAFTER', 1, '1차 결재: 팀장', NOW()),
('GENERAL_PROPOSAL', 'HEAD', 'DRAFTERT', 2, '2차 결재: 본부장', NOW()),
('GENERAL_PROPOSAL', 'CEO', 'MANAGEMENT', 3, '최종 승인: 대표이사', NOW());

INSERT INTO APPROVAL_LINE_CONFIG (DOC_TYPE, POSITION, DEPARTMENT, APPROVAL_ORDER)
VALUES
('EXPENSE_REPORT', 'TEAM_LEADER', 'DFRAFTER', 1),
('EXPENSE_REPORT', 'HEAD', 'DFRAFTER', 2),
('EXPENSE_REPORT', 'CEO', 'MANAGEMENT', 3);



