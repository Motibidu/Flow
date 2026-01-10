package com.flow.coretime.elecApproval.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.common.enums.DepartmentType;
import com.flow.coretime.elecApproval.enums.DocumentType;
import com.flow.coretime.elecApproval.model.ApprovalLineConfigRespDto;
import com.flow.coretime.elecApproval.model.ElecApprovalLineConfigEntity;

@Mapper
public interface ElecApprovalLineConfigMapper {
        List<ElecApprovalLineConfigEntity> getApprovalConfigList(DocumentType docType, String userId);

        List<ApprovalLineConfigRespDto> getApprovalLineConfigRespDto(
                        @Param("userId") String userId,
                        @Param("department") DepartmentType department,
                        @Param("docType") DocumentType docType);
}
