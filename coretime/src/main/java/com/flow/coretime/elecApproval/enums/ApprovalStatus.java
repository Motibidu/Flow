package com.flow.coretime.elecApproval.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ApprovalStatus {
    WAIT("대기"), // 이전 결재자가 아직 승인하지 않음
    PENDING("결재대기"), // 현재 내가 결재할 차례
    APPROVED("승인"), // 승인 완료
    REJECTED("반려"), // 반려 완료
    RECALLED("취소"); // 기안자가 문서를 취소함

    private final String displayName;

    public static ApprovalStatus fromString(String value) {
        try {
            return ApprovalStatus.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("유효하지 않은 결재 상태입니다: " + value);
        }
    }

    public void validateCommentWhenRejected(String comment) {
        if (this == ApprovalStatus.REJECTED) {
            if (comment == null || comment.trim().isEmpty()) {
                throw new IllegalArgumentException("반려 시에는 의견을 필수로 입력해야 합니다.");
            }
        }
    }

}
