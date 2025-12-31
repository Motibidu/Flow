package com.flow.coretime.elecApproval.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfig;

@Mapper
public interface ElecApprovalLineConfigMapper {
        List<ElecApprovalLineConfig> getApprovalConfigList(DocumentType docType);

}
