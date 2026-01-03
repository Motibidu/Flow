package com.flow.coretime.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DepartmentType {
        ADMIN("ADMIN", "관리자"),
        HR("HR", "인사팀"),
        SALES("SALES", "영업팀"),
        DEV("DEV", "개발팀"),
        PLANNING("PLANNING", "기획팀"),
        MARKETING("MARKETING", "마케팅팀"),
        SUPPORT("SUPPORT", "고객지원팀"),
        MANAGEMENT("MANAGEMENT", "경영지원팀");

        private final String code;
        private final String description;
}
