package com.flow.coretime.elecApproval.model;

import java.util.List;
import lombok.Data;

@Data
public class MyLineResponseDto {
        private Long lineId; // 결재선 고유 ID

        private String title; // 결재선 이름

        private List<MyLineDetailDto> approvers;

}
