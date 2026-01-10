package com.flow.coretime.global.exception;

public class UnauthorizedException extends RuntimeException {
        public UnauthorizedException(String message) {
                super(message);
        }
        public UnauthorizedException(org.springframework.http.HttpStatus status, String message) {
                super(message);
        }
        
}
