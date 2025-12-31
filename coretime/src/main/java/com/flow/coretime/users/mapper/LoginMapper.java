package com.flow.coretime.users.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface LoginMapper {
       public List<String> findIdByEmail(@Param("email") String email);
}
