package com.flow.coretime.elecApproval.mapper;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.elecApproval.model.Document;
import com.flow.coretime.elecApproval.model.DocumentEntity;

@Mapper
public interface ElecApprovalMapper {
        List<Document> findDocumentsToApprove(@Param("approverId") String approverId);

        List<Document> findInProgressDocumentsByInitiatorId(@Param("initiatorId") String initiatorId);

        List<Document> findRejectedOrRecalledDocuments(String currentUserId);

        List<Document> findApprovedDocumentsByInitiatorId(@Param("initiatorId") String initiatorId);

        void insertDocument(Document document);

        Optional<Document> getDocumentById(@Param("docId") int docId);

        void updateDocumentStatus(Document document);

        int cancelApproval(Map<String, Object> params);

        void deletePendingHistory(Long docId);

        int updateDocumentForRedraft(Document redraftData);

        void deleteDocument(int docId);

        void insertDocumentEntity(DocumentEntity documentEntity);

}
