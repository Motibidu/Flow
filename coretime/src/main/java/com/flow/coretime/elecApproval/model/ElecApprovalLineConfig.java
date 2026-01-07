package com.flow.coretime.elecApproval.model;

import java.time.LocalDateTime;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.PositionType;
import com.flow.coretime.elecApproval.enums.DocumentType;

import lombok.Data;

@Data
public class ElecApprovalLineConfig {
        private Integer configId; // 설정 고유 번호
        private DocumentType docType; // 문서 종류
        private PositionType position; // 직급
        private DepartmentType department; // 부서
        private Integer approvalOrder; // 결재 순서
        private String description; // 설정 설명
        private LocalDateTime createdAt; // 설정 생성일

}
