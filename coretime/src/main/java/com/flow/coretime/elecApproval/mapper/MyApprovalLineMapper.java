package com.flow.coretime.elecApproval.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.elecApproval.model.MyApprovalLineDetailEntity;
import com.flow.coretime.elecApproval.model.MyApprovalLineEntity;
import com.flow.coretime.elecApproval.model.MyLineResponseDto;

@Mapper
public interface MyApprovalLineMapper {
        List<MyLineResponseDto> findMyApprovalLines(@Param("userId") String userId);

        void insertMyApprovalLine(MyApprovalLineEntity myApprovalLineEntity);

        void insertMyApprovalLineDetail(List<MyApprovalLineDetailEntity> details);

        void deleteMyApprovalLine(@Param("userId") String userId, @Param("lineId") int lineId);

        void deleteMyApprovalLineDetail(@Param("lineId") int lineId);

}
