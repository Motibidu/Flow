package com.flow.coretime.common.enums;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
@JsonFormat(shape = JsonFormat.Shape.OBJECT)
public enum RankType {
    STAFF("사원", 1),
    ASSISTANT_MANAGER("대리", 2),
    MANAGER("과장", 3),
    SENIOR_MANAGER("차장", 4),
    TEAM_LEADER("부장", 5),
    DIRECTOR("이사", 6),
    CEO("대표이사", 7);

    private final String displayName;
    private final int level;

    public boolean isHigherThan(RankType other) {
        return this.level > other.level;
    }
}
