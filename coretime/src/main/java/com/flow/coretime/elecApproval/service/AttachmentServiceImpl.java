package com.flow.coretime.elecApproval.service;

import com.flow.coretime.elecApproval.mapper.ElecApprovalMapper;
import com.flow.coretime.elecApproval.model.AttachmentEntity;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class AttachmentServiceImpl implements AttachmentService {

    @Value("${upload.dir}")
    private String uploadDir;

    private final ElecApprovalMapper elecApprovalMapper;

    @Override
    @Transactional
    public void saveAttachments(int docId, List<MultipartFile> files) {
        File dir = new File(uploadDir);
        log.info("uploadDir: {}", uploadDir);
        if (!dir.exists())
            dir.mkdirs();

        for (MultipartFile file : files) {
            if (file.isEmpty())
                continue;

            String originName = file.getOriginalFilename();
            String savedName = UUID.randomUUID().toString() + "_" + originName;
            File dest = new File(dir, savedName);

            try {
                file.transferTo(dest);
                AttachmentEntity attachment = AttachmentEntity.builder()
                        .docId(docId)
                        .originName(originName)
                        .savedName(savedName)
                        .filePath(dest.getAbsolutePath())
                        .fileSize(file.getSize())
                        .build();
                log.info("attachment: {}", attachment);
                elecApprovalMapper.insertAttachment(attachment);
            } catch (IOException e) {
                throw new RuntimeException("파일 업로드 중 오류 발생", e);
            }
        }
    }

    @Override
    public AttachmentEntity getAttachment(Long fileId) {
        return elecApprovalMapper.selectAttachmentByDocId(fileId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "파일을 찾을 수 없습니다."));
    }

    @Override
    @Transactional
    public void deleteAttachmentsAndFiles(List<Long> deleteFileIds) {
        if (deleteFileIds != null && !deleteFileIds.isEmpty()) {
            // A. 실제 파일 삭제 (로컬 디스크)
            List<AttachmentEntity> filesToDelete = elecApprovalMapper.selectAllByIds(deleteFileIds);
            for (AttachmentEntity file : filesToDelete) {
                deleteFileFromDisk(file.getSavedName()); // 파일 삭제 유틸 메서드 호출
            }
            // B. DB 데이터 삭제
            elecApprovalMapper.deleteByIds(deleteFileIds);
        }
    }

    @Override
    @Transactional
    public void deleteAttachmentsByDocId(int docId) {
        List<AttachmentEntity> attachments = elecApprovalMapper.selectAttachmentsByDocId(docId);
        if (attachments != null && !attachments.isEmpty()) {
            for (AttachmentEntity attachment : attachments) {
                File file = new File(attachment.getFilePath());
                if (file.exists()) {
                    file.delete();
                }
            }
            elecApprovalMapper.deleteAttachmentsByDocId(docId);
        }
    }

    private void deleteFileFromDisk(String savedName) {
        File file = new File(uploadDir, savedName);
        if (file.exists()) {
            file.delete();
        }
    }
}
