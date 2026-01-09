package com.flow.coretime.elecApproval.model;

import java.util.Date;
import java.util.List;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.common.enums.RankType;
import com.flow.coretime.elecApproval.enums.ApprovalStatus;
import com.flow.coretime.elecApproval.enums.DocumentStatus;
import com.flow.coretime.elecApproval.enums.DocumentType;

import lombok.Data;

@Data
public class DocumentRespDto {
        // 테이블 컬럼
        private int docId;

        // jsp에서 가져옴
        private DocumentType docType;
        private String title;
        private String jsonContent;

        // service에서 채움
        private DocumentStatus status;
        private Date draftDate;
        private Date updatedAt;

        // JOIN테이블: USERS, service에서 채움
        private String initiatorId;
        private String initiatorName;
        private RankType initiatorRank;
        private DepartmentType initiatorDepartment;

        // JOIN테이블: APPROVAL_HISTORY
        private String currentApproverName;

        
        private List<AttachmentEntity> attachments;
        private List<ElecApprovalHistory> approvalHistories;

        public String getInitiatorDepartmentName() {
                return initiatorDepartment != null ? initiatorDepartment.getDisplayName() : "";
        }

        // 현재 결재 대기중인 사람의 ID를 반환하는 편의 메서드 (JSP에서 ${document.currentApproverId}로 사용 가능)
        public String getCurrentApproverId() {
                if (approvalHistories == null) return null;
                return approvalHistories.stream()
                        .filter(h -> ApprovalStatus.PENDING.equals(h.getApprovalStatus()))
                        .findFirst()
                        .map(ElecApprovalHistory::getApproverId)
                        .orElse(null);
        }
}
