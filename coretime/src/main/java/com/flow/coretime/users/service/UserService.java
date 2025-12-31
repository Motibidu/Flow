
package com.flow.coretime.users.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.flow.coretime.users.exception.UserAlreadyExistsException;
import com.flow.coretime.users.mapper.UserMapper;
import com.flow.coretime.users.model.User;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

@Service
public class UserService implements UserDetailsService {

	private final UserMapper userMapper;
	private final PasswordEncoder passwordEncoder;

	@Value("${app.upload.profile-image-dir}")
	private String uploadDir;

	public UserService(UserMapper userMapper, PasswordEncoder passwordEncoder) {
		this.userMapper = userMapper;
		this.passwordEncoder = passwordEncoder;
	}

	// find =============================
	public PageInfo<User> findUsersWithPagination(int pageNum, int pageSize) {
		PageHelper.startPage(pageNum, pageSize);
		List<User> userList = userMapper.findAllUsers();

		return new PageInfo<>(userList);
	}

	public List<User> findAllUsers() {
		return userMapper.findAllUsers();
	}

	// public User findById(String id) {
	// User foundUser = userMapper.findById(id);
	// foundUser.setPassword(null);
	// return foundUser;
	// }

	public Optional<User> findById(String id) {
		return userMapper.findById(id);
	}

	// insert=============================
	public void insertUser(User user, MultipartFile profileImage) {
		if (userMapper.countById(user.getId()) > 0) {
			throw new UserAlreadyExistsException("이미 사용 중인 아이디입니다.");
		}
		if (profileImage != null && !profileImage.isEmpty()) {
			// 업로드 디렉토리가 없으면 생성
			Path uploadPath = Paths.get(uploadDir);
			if (!Files.exists(uploadPath)) {
				try {
					Files.createDirectories(uploadPath);
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			String originalFilename = profileImage.getOriginalFilename();
			String fileExtension = "";
			if (originalFilename != null && originalFilename.contains(".")) {
				fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
			}
			String newFilename = UUID.randomUUID().toString() + fileExtension;
			Path filePath = uploadPath.resolve(newFilename);

			// 파일 저장
			try {
				Files.copy(profileImage.getInputStream(), filePath);
			} catch (IOException e) {
				e.printStackTrace();
			}

			// User 객체에 이미지 경로 저장 (DB에 저장될 경로)
			user.setProfileImagePath("/resources/upload/" + newFilename); // 웹 접근 경로
		} else {
			user.setProfileImagePath("/resources/images/person.svg");
		}
		user.setPassword(passwordEncoder.encode(user.getPassword()));
		user.setCreatedAt(LocalDate.now());
		user.setUpdatedAt(LocalDate.now());
		user.setRole("ROLE_USER");
		userMapper.insertUser(user);
	}

	// update=============================
	public void updateUserByExistingId(String existingId, MultipartFile profileImage, User newUserInfo) {
		// 기존 정보 찾기
		User existingUser = userMapper.findById(existingId).orElseThrow();
		if (existingUser == null) {
			throw new UsernameNotFoundException("User with ID " + existingId + " not found.");
		}

		// 기존 이미지 파일 삭제 && 새로운 이미지 경로 설정
		if (profileImage != null && !profileImage.isEmpty()) {
			if (existingUser.getProfileImagePath() != null
					&& !existingUser.getProfileImagePath().isEmpty()) {
				try {
					deleteProfileImage(existingUser.getProfileImagePath());
				} catch (IOException e) {
					System.err.println("Error deleting old profile image: " + e.getMessage());
				}
			}
			newUserInfo.setProfileImagePath(saveProfileImage(profileImage));
		}

		newUserInfo.setUpdatedAt(LocalDate.now());
		userMapper.updateUserByExistingId(existingId, newUserInfo);
	}

	public void deleteUsersByIds(List<String> userIds) {
		for (String existingId : userIds) {
			User existingUser = userMapper.findById(existingId).orElseThrow();
			if (existingUser.getProfileImagePath() != null
					&& !existingUser.getProfileImagePath().isEmpty()) {
				try {
					deleteProfileImage(existingUser.getProfileImagePath());
				} catch (IOException e) {
					System.err.println("Error deleting old profile image: " + e.getMessage());
				}
			}
		}
		userMapper.deleteUsersByIds(userIds);
	}

	private void deleteProfileImage(String webPath) throws IOException {
		// 웹 경로 (/resources/upload/파일명.확장자)를 실제 파일 시스템 경로로 변환
		if (webPath != null && webPath.startsWith("/resources/upload/")) {
			String filename = webPath.substring("/resources/upload/".length());
			Path filePath = Paths.get(uploadDir, filename);

			if (Files.exists(filePath)) {
				Files.delete(filePath);
				System.out.println("Deleted old profile image: " + filePath.toString());
			} else {
				System.out.println("Old profile image not found at: " + filePath.toString());
			}
		}
	}

	private String saveProfileImage(MultipartFile profileImage) {
		if (profileImage == null || profileImage.isEmpty()) {
			return null;
		}

		Path uploadPath = Paths.get(uploadDir);
		if (!Files.exists(uploadPath)) {
			try {
				Files.createDirectories(uploadPath);
			} catch (IOException e) {
				e.printStackTrace();
				throw new RuntimeException("Failed to create upload directory", e);
			}
		}

		String originalFilename = profileImage.getOriginalFilename();
		String fileExtension = "";
		if (originalFilename != null && originalFilename.contains(".")) {
			fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
		}
		String newFilename = UUID.randomUUID().toString() + fileExtension;
		Path filePath = uploadPath.resolve(newFilename);

		try {
			Files.copy(profileImage.getInputStream(), filePath);
		} catch (IOException e) {
			e.printStackTrace();
			throw new RuntimeException("Failed to save profile image", e);
		}

		return "/resources/upload/" + newFilename; // 웹 접근 경로 반환
	}

	@Override
	public UserDetails loadUserByUsername(String id) throws UsernameNotFoundException {
		User user = userMapper.findById(id)
				.orElseThrow(() -> new UsernameNotFoundException("User not found with id: " + id));
		System.out.println(user.getId());

		List<GrantedAuthority> authorities = Arrays.stream(user.getRole().split(","))
				.map(SimpleGrantedAuthority::new)
				.collect(Collectors.toList());

		return new org.springframework.security.core.userdetails.User(user.getId(), // 사용자 아이디 (로그인에 사용될 식별자)
				user.getPassword(), // 암호화된 비밀번호 (DB에서 가져온 그대로)
				authorities // 사용자 권한 목록
		);
	}

}
