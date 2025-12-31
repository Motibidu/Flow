CREATE TABLE users (
    id VARCHAR(50) NOT NULL PRIMARY KEY, -- ID를 기본키로 설정하는 것이 좋습니다.
    name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(50) NOT NULL,
    tel VARCHAR(50) NOT NULL,
    rank_name VARCHAR(50) NOT NULL,      -- 'rank'는 MySQL 예약어이므로 이름을 바꾸는 것을 추천합니다.
    department VARCHAR(50) NOT NULL,
    PROFILEIMAGEPATH VARCHAR(255),
    birth DATE NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    role VARCHAR(10)
);

INSERT INTO users (id, name, password, email, tel, rank_name, department, birth, role)
VALUES 
('dev_emp', '김사원', '$2a$12$Y8tBFI3YC7AZkrK7QgdJYO72YBJIzIz33.75xa5YhCxOqRlFtrsDi', 'dev_emp@coretime.com', '010-1111-1111', '사원', '개발팀', '1995-05-20', 'ROLE_USER'),
('dev_mgr', '이팀장', '$2a$12$Y8tBFI3YC7AZkrK7QgdJYO72YBJIzIz33.75xa5YhCxOqRlFtrsDi', 'dev_mgr@coretime.com', '010-2222-2222', '팀장', '개발팀', '1988-03-15', 'ROLE_USER'),
('dev_dir', '박본부장', '$2a$12$Y8tBFI3YC7AZkrK7QgdJYO72YBJIzIz33.75xa5YhCxOqRlFtrsDi', 'dev_dir@coretime.com', '010-3333-3333', '본부장', '개발팀', '1980-10-05', 'ROLE_USER'),
('dev_pres', '김대표이사', '$2a$12$Y8tBFI3YC7AZkrK7QgdJYO72YBJIzIz33.75xa5YhCxOqRlFtrsDi', 'dev_pres@coretime.com', '010-4444-4444', '대표이사', '개발팀', '1970-10-05', 'ROLE_USER'),
('hr_mgr', '최인사', '$2a$12$Y8tBFI3YC7AZkrK7QgdJYO72YBJIzIz33.75xa5YhCxOqRlFtrsDi', 'hr_mgr@coretime.com', '010-4444-4444', '팀장', '인사팀', '1985-07-12', 'ROLE_USER');

INSERT INTO USERS (ID, NAME, PASSWORD, DEPARTMENT, RANK_NAME)
VALUES ('admin_leader', '관리팀장', '1234', '관리자', '팀장');