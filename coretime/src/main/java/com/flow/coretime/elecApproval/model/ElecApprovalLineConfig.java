package com.flow.coretime.elecApproval.model;

import java.time.LocalDateTime;

import com.flow.coretime.elecApproval.enums.DocumentType;

import lombok.Data;

@Data
public class ElecApprovalLineConfig {
        private Integer configId; // 설정 고유 번호 (PK)
        private DocumentType docType; // 문서 종류 (예: vacationRequestForm, 휴가신청서)
        private String targetRank; // 결재 대상 직급 (예: 팀장, 본부장, 대표이사)
        private String deptType; // 부서 기준 (예: MY_DEPT - 기안자 부서, HR_DEPT - 특정 부서)
        private Integer approvalOrder; // 결재 순서 (1, 2, 3...)
        private String description; // 설정 설명 (예: 1차 팀장 결재)
        private LocalDateTime createdAt; // 설정 생성일

}
