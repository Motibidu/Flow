package com.flow.coretime.elecApproval.mapper;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.elecApproval.enums.DocumentStatus;
import com.flow.coretime.elecApproval.model.AttachmentEntity;
import com.flow.coretime.elecApproval.model.DocumentRespDto;
import com.flow.coretime.users.model.User;
import com.flow.coretime.elecApproval.model.DocumentEntity;

@Mapper
public interface ElecApprovalMapper {
        // select
        List<DocumentRespDto> selectDocumentsToApprove(@Param("approverId") String approverId);

        List<DocumentRespDto> selectInProgressDocumentsByInitiatorId(@Param("initiatorId") String initiatorId);

        List<DocumentRespDto> selectRejectedOrRecalledDocuments(String currentUserId);

        List<DocumentRespDto> selectApprovedDocumentsByInitiatorId(@Param("initiatorId") String initiatorId);

        Optional<DocumentRespDto> selectDocumentById(@Param("docId") int docId);

        // insert
        void insertDocument(DocumentRespDto document);

        void insertDocumentEntity(DocumentEntity documentEntity);

        void insertAttachment(AttachmentEntity attachment);

        // update
        int updateDocumentStatus(DocumentRespDto document);

        int updateDocumentForRedraft(DocumentRespDto attachment);

        // delete
        void deleteDocument(int docId);

        void deletePendingHistory(Long docId);

        // etc
        int recallDocument(@Param("docId") int docId, @Param("userId") String userId, @Param("version") int version);

        List<AttachmentEntity> selectAttachmentsByDocId(@Param("docId") int docId);

        Optional<AttachmentEntity> selectAttachmentByDocId(Long fileId);

        List<DocumentRespDto> selectAllPendingOrInProgress(String username);

        List<DocumentRespDto> selectAllRejectedOrRecalled(String username);

        List<DocumentRespDto> selectAllApproved(String username);

        List<DocumentRespDto> selectAllTemp(String username);

        void updateTempDocumentEntity(DocumentEntity documentEntity);

        List<DocumentRespDto> selectAllMyTurn(String username);

        void deleteAttachmentsByDocId(int docId);

        List<DocumentRespDto> selectMyTurnByKeyword(
            @Param("userId") String userId,
            @Param("searchType") String searchType,
            @Param("keyword") String keyword
    );

        List<DocumentRespDto> selectByStatusAndKeyword(
                        @Param("userId") String userId,
                        @Param("statusList") List<DocumentStatus> statusList,
                        @Param("searchType") String searchType,
                        @Param("keyword") String keyword);

        void updateAttachmentsForRedraft(AttachmentEntity attachment);

        List<AttachmentEntity> selectAllByIds(@Param("ids") List<Long> deleteFileIds);

        void deleteByIds(@Param("ids") List<Long> deleteFileIds);

}
