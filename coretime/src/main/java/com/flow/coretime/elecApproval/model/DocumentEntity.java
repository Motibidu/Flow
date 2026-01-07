package com.flow.coretime.elecApproval.model;

import java.util.Date;

import com.flow.coretime.elecApproval.enums.DocumentStatus;
import com.flow.coretime.elecApproval.enums.DocumentType;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DocumentEntity {
        private int docId;
        private DocumentType docType;
        private String title;
        private DocumentStatus status;
        private String initiatorId;
        private Date draftDate;
        private String jsonContent;
        private Date updatedAt;

}
