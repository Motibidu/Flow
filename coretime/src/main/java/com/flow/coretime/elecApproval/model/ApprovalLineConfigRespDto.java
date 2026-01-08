package com.flow.coretime.elecApproval.model;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.PositionType;

import lombok.Data;

@Data
public class ApprovalLineConfigRespDto {
        private String userId;
        private String userName;
        private PositionType position;
        private DepartmentType department;
}
