
package com.flow.coretime.users.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.flow.coretime.users.exception.UserAlreadyExistsException;
import com.flow.coretime.users.model.User;
import com.flow.coretime.users.service.UserService;


import jakarta.validation.Valid;

@Controller
@RequestMapping("/users")
public class UserController {

	private final UserService userService;

	public UserController(UserService userService) {
		this.userService = userService;
	}

	@GetMapping
	public String showUsers(@AuthenticationPrincipal UserDetails userDetails, Model model) {
		List<User> userList = userService.findAllUsers();
		model.addAttribute("userList", userList); // 현재 페이지의 사용자 목록
		model.addAttribute("currentUserId", userDetails.getUsername());
		model.addAttribute("currentUserAuthority",
				userDetails.getAuthorities().stream().findFirst().get().getAuthority().trim());

		return "users";
	}

	@GetMapping("/list")
	public String showUserList(Model model) {
		List<User> userList = userService.findAllUsers(); // 서비스에서 모든 사용자 가져오기
		model.addAttribute("userList", userList); // 모델에 리스트 추가

		return "userList";
	}

	@GetMapping("/new")
	public String showUserForm(@AuthenticationPrincipal UserDetails userDetails, Model model) {
		model.addAttribute("user", new User());
		model.addAttribute("currentUserId", userDetails.getUsername());
		model.addAttribute("currentUserAuthority",
				userDetails.getAuthorities().stream().findFirst().get().getAuthority().trim());

		return "userForm";
	}

	@PostMapping("/insert")
	public String insertUser(@Valid @ModelAttribute User user, BindingResult bindingResult,
			@RequestParam("profileImage") MultipartFile profileImage, Model model) {
		if (bindingResult.hasErrors()) {
			System.out.println("Validation errors: " + bindingResult.getAllErrors());
			return "userForm";
		}

		try {
			userService.insertUser(user, profileImage);
		} catch (UserAlreadyExistsException e) {
			bindingResult.addError(
					new FieldError("user", "id", user.getId(), false, null, null, e.getMessage()));
			model.addAttribute("user", user);
			return "userForm";
		} catch (Exception e) {
			System.err.println("Unhandled Exception during user insertion: " + e.getMessage());
			model.addAttribute("errorMessage", "사용자 등록 중 알 수 없는 오류가 발생했습니다.");
			model.addAttribute("user", user);

			return "userForm";
		}

		return "redirect:/users";
	}

	@PostMapping("/delete")
	public ResponseEntity<Map<String, String>> deleteUsers(@RequestBody Map<String, List<String>> payload) {
		List<String> userIds = payload.get("ids");
		try {
			if (userIds == null || userIds.isEmpty()) {
				return ResponseEntity.badRequest().body(Map.of("message", "삭제할 사용자 ID가 없습니다."));
			}
			userService.deleteUsersByIds(userIds);
			return ResponseEntity.ok(Map.of("message", "사용자가 성공적으로 삭제되었습니다."));
		} catch (Exception e) {
			return ResponseEntity.internalServerError()
					.body(Map.of("message", "사용자 삭제 중 오류 발생: " + e.getMessage()));
		}
	}

	@GetMapping("/edit")
	public String showEditUser(@AuthenticationPrincipal UserDetails userDetails,
			@RequestParam("existingId") String existingId, Model model) {
		User user = userService.findById(existingId).orElseThrow(
				() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."));
		model.addAttribute("user", user);
		model.addAttribute("currentUserId", userDetails.getUsername());
		model.addAttribute("currentUserAuthority",
				userDetails.getAuthorities().stream().findFirst().get().getAuthority().trim());

		return "edit";
	}

	@PostMapping("/edit")
	public String editUser(@RequestParam("existingId") String existingId,
			@RequestParam("profileImage") MultipartFile profileImage, @ModelAttribute User newUserInfo) {
		userService.updateUserByExistingId(existingId, profileImage, newUserInfo);
		return "redirect:/users";
	}

}
