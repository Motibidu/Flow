package com.flow.coretime.elecApproval.service;

import com.flow.coretime.elecApproval.model.AttachmentEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface AttachmentService {

    void saveAttachments(int docId, List<MultipartFile> files);

    AttachmentEntity getAttachment(Long fileId);

    void deleteAttachmentsAndFiles(List<Long> deleteFileIds);

    void deleteAttachmentsByDocId(int docId);
}
