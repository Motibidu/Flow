package com.flow.coretime.elecApproval.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DocumentType {
    VACATION_REQUEST("vacationRequestForm", "휴가신청서"),
    GENERAL_PROPOSAL("generalProposalForm", "일반품의서"),
    EXPENSE_REPORT("expenseReportForm", "지출결의서");

    private final String dbValue; // DB에 저장될 문자열
    private final String displayName; // 화면에 보일 한글명
}
