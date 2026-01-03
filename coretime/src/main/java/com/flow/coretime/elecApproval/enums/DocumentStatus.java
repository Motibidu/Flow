package com.flow.coretime.elecApproval.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DocumentStatus {
        DRAFT("임시저장"),
        PENDING("결재대기"), // 첫 번째 결재자 대기
        IN_PROGRESS("결재중"), // 일부 승인 완료
        APPROVED("최종승인"), // 모든 결재자 승인 완료
        REJECTED("반려"), // 결재자 중 한 명이라도 반려
        RECALLED("상신취소"); // 기안자가 직접 취소

        private final String description;
}
