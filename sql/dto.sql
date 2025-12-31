CREATE TABLE users (
    id VARCHAR(50) NOT NULL PRIMARY KEY, -- ID를 기본키로 설정하는 것이 좋습니다.
    name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(50) NOT NULL,
    tel VARCHAR(50) NOT NULL,
    rank_name VARCHAR(50) NOT NULL,      -- 'rank'는 MySQL 예약어이므로 이름을 바꾸는 것을 추천합니다.
    department VARCHAR(50) NOT NULL,
    birth DATE NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    role VARCHAR(10)
);