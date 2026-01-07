package com.flow.coretime.elecApproval.model;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.PositionType;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ApproverCandidateDto {
        private String userId;
        private String name;
        private PositionType position;
        private DepartmentType department;
}
