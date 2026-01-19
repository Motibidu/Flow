package com.flow.coretime.users.mapper;

import com.flow.coretime.users.model.SubstituteApproval;
import com.flow.coretime.users.model.SubstituteApprovalResponseDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Mapper
public interface SubstituteApprovalMapper {

    List<SubstituteApprovalResponseDto> findByDelegatorId(@Param("delegatorId") String delegatorId);

    void insert(SubstituteApproval substituteApproval);

    void delete(@Param("id") Long id, @Param("delegatorId") String delegatorId);

    Optional<SubstituteApproval> findActiveSubstitute(@Param("delegatorId") String delegatorId, @Param("currentDate") Date currentDate);
}
