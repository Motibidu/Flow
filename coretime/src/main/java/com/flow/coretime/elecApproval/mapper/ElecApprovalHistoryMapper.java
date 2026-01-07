package com.flow.coretime.elecApproval.mapper;

import com.flow.coretime.elecApproval.model.ElecApprovalHistory;
import com.flow.coretime.elecApproval.model.ElecApprovalHistoryEntity;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List; // List 임포트 추가
import java.util.Optional;

@Mapper
public interface ElecApprovalHistoryMapper {
        void insertApprovalHistoryEntity(ElecApprovalHistory approvalHistory);

        void updateApprovalHistory(ElecApprovalHistory approvalHistory);

        Optional<ElecApprovalHistory> findCurrentPendingApproval(@Param("docId") int docId);

        Optional<ElecApprovalHistory> findNextApprover(@Param("docId") int docId,
                        @Param("currentOrder") int currentOrder);

        // 특정 문서의 모든 결재 이력 조회 메서드 추가
        List<ElecApprovalHistory> findApprovalHistoryByDocId(@Param("docId") int docId);

        void insertApprovalHistories(@Param("histories") List<ElecApprovalHistory> histories);

        void deleteHistoryByDocId(int docId);

        void insertApprovalHistoryEntities(@Param("histories") List<ElecApprovalHistoryEntity> histories);
}