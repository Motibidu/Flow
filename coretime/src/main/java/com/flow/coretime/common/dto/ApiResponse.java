
package com.flow.coretime.common.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ApiResponse<T> {
        private boolean success; // 성공 여부 (true/false)
        private String message; // 응답 메시지 (예: "저장 성공", "에러 발생")
        private T data; // 실제 데이터 (없으면 null)

        // [성공] 데이터 없이 메시지만 보낼 때
        public static <T> ApiResponse<T> success(String message) {
                return new ApiResponse<>(true, message, null);
        }

        // [성공] 성공 메시지와 데이터 보낼 때
        public static <T> ApiResponse<T> success(T data) {
                return new ApiResponse<>(true, "요청이 성공적으로 처리되었습니다.", data);
        }

        // [성공] 커스텀 메시지와 데이터 모두 보낼 때
        public static <T> ApiResponse<T> success(String message, T data) {
                return new ApiResponse<>(true, message, data);
        }

        // [실패] 에러 메시지 보낼 때
        public static <T> ApiResponse<T> error(String message) {
                return new ApiResponse<>(false, message, null);
        }
}
