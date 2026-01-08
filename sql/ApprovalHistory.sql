CREATE TABLE APPROVAL_HISTORY (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    doc_id INT NOT NULL,                    -- 문서 ID
    approver_id VARCHAR(50) NOT NULL,       -- 결재자 ID
    approval_status VARCHAR(20) NOT NULL,   -- 결재 상태 (PENDING, APPROVED, REJECTED
    comments TEXT,                          -- 결재 의견
    action_date DATETIME,                   -- 결재 처리 일시
    approval_order INT,                         -- 결재 순서
    FOREIGN KEY (doc_id) REFERENCES DOCUMENTS(doc_id) ON DELETE CASCADE,
    FOREIGN KEY (approver_id) REFERENCES USERS(id)
);