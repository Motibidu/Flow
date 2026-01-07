package com.flow.coretime.elecApproval.model;

import java.util.List;

import com.flow.coretime.elecApproval.enums.DocumentType;

import lombok.Data;

@Data
public class DocumentReqDto {
        private String title;
        private DocumentType docType;
        private String jsonContent;
        private List<String> approverIds;
}
