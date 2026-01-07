package com.flow.coretime.elecApproval.model;

import java.util.List;
import lombok.Data;

@Data
public class MyLineSaveDto {
        private String title; // 결재선 제목
        private List<String> approverIds; // 결재자 ID 목록 (순서대로 들어옴)
}
