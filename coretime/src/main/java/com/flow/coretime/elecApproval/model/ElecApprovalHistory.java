package com.flow.coretime.elecApproval.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

import com.flow.coretime.common.enums.RankType;
import com.flow.coretime.elecApproval.enums.ApprovalStatus;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ElecApprovalHistory {
        private int historyId;
        private int docId;
        private String approverId;
        private ApprovalStatus approvalStatus;
        private int approvalOrder;
        private String commentText;

        // 승인 또는 반려가 처리된 시점
        private Date actionDate;

        // 결재선 표시를 위한 추가 필드 (JOIN 또는 UserService 호출로 채워짐)
        private String approverName; // USERS.NAME
        private RankType approverRank; // USERS.RANK (User 모델에 rank 필드가 있다면)
}
