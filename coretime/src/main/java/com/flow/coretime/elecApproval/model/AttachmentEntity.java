package com.flow.coretime.elecApproval.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AttachmentEntity {
        private Long id;
        private int docId;
        private String originName;
        private String savedName;
        private String filePath;
        private long fileSize;
}