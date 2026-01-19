package com.flow.coretime.elecApproval.model;

import java.util.Date;

import com.flow.coretime.elecApproval.enums.ApprovalStatus;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ElecApprovalHistoryEntity {
        private int historyId;
        private int docId;
        private String approverId;
        private ApprovalStatus approvalStatus;
        private String comments;
        private Date actionDate;
        private int approvalOrder;
        private String actingApproverId; // 대리 결재자 ID

}
