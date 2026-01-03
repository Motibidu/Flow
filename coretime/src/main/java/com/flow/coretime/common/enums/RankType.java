package com.flow.coretime.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum RankType {
    // 코드("한글명", 서열레벨)
    // 레벨이 높을수록 높은 직급으로 가정 (CEO가 가장 높음)
    STAFF("사원", 1),
    ASSISTANT_MANAGER("대리", 2),
    MANAGER("과장", 3),
    SENIOR_MANAGER("차장", 4),
    TEAM_LEADER("부장", 5),
    DIRECTOR("이사", 6),
    CEO("대표이사", 7);

    private final String description;
    private final int level;

    // 특정 직급보다 높은지 확인하는 메서드 (결재 로직에서 활용 가능)
    public boolean isHigherThan(RankType other) {
        return this.level > other.level;
    }
}
