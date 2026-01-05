package com.flow.coretime.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum PositionType {
    // 코드("DB저장명", "화면표시명", 권한레벨)
    MEMBER("MEMBER", "팀원", 1),
    TEAM_LEADER("TEAM_LEADER", "팀장", 2),
    HEAD("HEAD", "본부장", 3),
    CEO("CEO", "대표이사", 4);

    private final String code;
    private final String displayName;
    private final int level; // 숫자가 높을수록 높은 직책

    // 특정 직책보다 상위 직책인지 확인 (결재 권한 체크용)
    public boolean isHigherThan(PositionType other) {
        return this.level > other.level;
    }
}
