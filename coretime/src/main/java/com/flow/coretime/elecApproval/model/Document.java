package com.flow.coretime.elecApproval.model;

import java.util.Date;

import com.flow.coretime.elecApproval.enums.DocumentType;

import lombok.Data;

@Data
public class Document {
        // 테이블 컬럼
        private int docId;
        private DocumentType docType;
        private String title;
        private String status;
        private Date draftDate;
        private String jsonContent;
        private Date updatedAt;

        // JOIN
        // 테이블: USERS
        private String initiatorId;
        private String initiatorName;
        private String initiatorRank;
        private String initiatorDepartment;

        // 테이블: APPROVAL_HISTORY
        private String currentApproverName;
}
