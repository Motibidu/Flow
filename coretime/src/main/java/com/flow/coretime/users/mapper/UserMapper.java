
package com.flow.coretime.users.mapper;

import java.util.List;
import java.util.Optional;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.flow.coretime.users.model.User;

@Mapper
public interface UserMapper {

	void insertUser(User user);

	Optional<User> findById(String id);

	List<User> findAllUsers();

	int countById(String id);

	void deleteUsersByIds(List<String> userIds);

	void updateUserByExistingId(@Param("existingId") String existingId, @Param("newUserInfo") User newUserInfo);

	Optional<String> findUserByDeptAndRank(@Param("department") String department,
			@Param("rankName") String rankName);
}