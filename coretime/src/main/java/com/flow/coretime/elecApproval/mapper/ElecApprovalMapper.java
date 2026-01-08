package com.flow.coretime.elecApproval.mapper;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.elecApproval.model.AttachmentEntity;
import com.flow.coretime.elecApproval.model.Document;
import com.flow.coretime.elecApproval.model.DocumentEntity;

@Mapper
public interface ElecApprovalMapper {
        // select
        List<Document> selectDocumentsToApprove(@Param("approverId") String approverId);

        List<Document> selectInProgressDocumentsByInitiatorId(@Param("initiatorId") String initiatorId);

        List<Document> selectRejectedOrRecalledDocuments(String currentUserId);

        List<Document> selectApprovedDocumentsByInitiatorId(@Param("initiatorId") String initiatorId);

        Optional<Document> getDocumentById(@Param("docId") int docId);

        // insert
        void insertDocument(Document document);

        void insertDocumentEntity(DocumentEntity documentEntity);

        void insertAttachment(AttachmentEntity attachment);

        // update
        void updateDocumentStatus(Document document);

        int updateDocumentForRedraft(Document redraftData);

        // delete
        void deleteDocument(int docId);

        void deletePendingHistory(Long docId);

        // etc
        int cancelApproval(Map<String, Object> params);

}
