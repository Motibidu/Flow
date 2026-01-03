package com.flow.coretime.global;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import lombok.extern.slf4j.Slf4j;

import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

        @ExceptionHandler(IllegalArgumentException.class)
        public ResponseEntity<Map<String, String>> handleIllegalArgumentException(IllegalArgumentException e) {
                log.error("비즈니스 로직 에러 발생: {}", e.getMessage());

                return new ResponseEntity<>(
                                Map.of("status", "error", "message", e.getMessage()),
                                HttpStatus.BAD_REQUEST);
        }

        @ExceptionHandler(Exception.class)
        public ResponseEntity<Map<String, String>> handleGeneralException(Exception e) {
                return new ResponseEntity<>(
                                Map.of("status", "error", "message", "서버 오류가 발생했습니다: " + e.getMessage()),
                                HttpStatus.INTERNAL_SERVER_ERROR);
        }
}
