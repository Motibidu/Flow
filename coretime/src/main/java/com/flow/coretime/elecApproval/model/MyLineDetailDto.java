package com.flow.coretime.elecApproval.model;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.PositionType;

import lombok.Data;

@Data
public class MyLineDetailDto {
        private String approverId; // 사번 (User ID)
        private String name; // 이름 (Join해서 가져옴)
        private PositionType position; // 직위명 (Join해서 가져옴)
        private DepartmentType department; // 부서명 (Join해서 가져옴)
        private Integer seq; // 순서
}
