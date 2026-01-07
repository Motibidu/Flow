package com.flow.coretime.elecApproval.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfig;
import com.flow.coretime.elecApproval.model.MyApprovalLineEntity;

@Mapper
public interface ElecApprovalLineConfigMapper {
        List<ElecApprovalLineConfig> getApprovalConfigList(DocumentType docType);

        List<ElecApprovalLineConfig> findMyApprovalLines(String userId);


}
