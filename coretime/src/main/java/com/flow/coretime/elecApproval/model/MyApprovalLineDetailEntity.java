package com.flow.coretime.elecApproval.model;

import lombok.Data;

@Data
public class MyApprovalLineDetailEntity {
        private Long id;
        private Long lineId;
        private String approverId;
        private Integer seq;
}
