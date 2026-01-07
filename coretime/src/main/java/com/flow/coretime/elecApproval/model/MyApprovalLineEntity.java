package com.flow.coretime.elecApproval.model;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MyApprovalLineEntity {
        private Long id;
        private String userId;
        private String title;
        private LocalDateTime createdAt;
}
