CREATE TABLE DOCUMENTS (
    doc_id INT AUTO_INCREMENT PRIMARY KEY,
    doc_type VARCHAR(50) NOT NULL,          -- 기안서 종류
    title VARCHAR(255) NOT NULL,            -- 제목
    status VARCHAR(20) DEFAULT 'PENDING',   -- 결재 상태 (PENDING, APPROVED, REJECTED)
    initiator_id VARCHAR(50) NOT NULL,      -- 기안자 ID (USERS 테이블의 ID 참조)
    draft_date DATETIME DEFAULT CURRENT_TIMESTAMP, -- 기안일
    json_content JSON,                      -- 상세 내용 (MySQL의 JSON 타입 활용)
    version INT NOT NULL DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (initiator_id) REFERENCES users(id)
);