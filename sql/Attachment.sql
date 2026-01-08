CREATE TABLE attachment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    doc_id INT NOT NULL,           -- 어느 문서의 파일인지
    origin_name VARCHAR(255),         -- 사용자가 올린 원래 파일명 (예: 영수증.jpg)
    saved_name VARCHAR(255),         -- 서버에 저장된 유니크한 이름 (예: uuid_영수증.jpg)
    file_path VARCHAR(500),                -- 저장 경로
    file_size BIGINT,                      -- 파일 크기
    FOREIGN KEY (doc_id) REFERENCES documents(DOC_ID)
);