CREATE TABLE board (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,        -- 게시글 번호 (자동 증가)
    author VARCHAR(50) NOT NULL,                 -- 작성자 이름/ID
    email VARCHAR(100),                          -- 작성자 이메일
    department_name VARCHAR(100),                -- 부서명
    title VARCHAR(255) NOT NULL,                 -- 제목
    content TEXT NOT NULL,                       -- 본문 (대용량 텍스트)
    view_count INT DEFAULT 0,                    -- 조회수
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- 작성일
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- 수정일
    board_type VARCHAR(20) DEFAULT 'FREE',       -- 게시판 타입 (NOTICE, FREE 등)
    role VARCHAR(50)                             -- 작성자 권한
);