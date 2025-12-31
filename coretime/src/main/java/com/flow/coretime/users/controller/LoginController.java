
package com.flow.coretime.users.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.flow.coretime.users.service.LoginService;

import org.springframework.web.bind.annotation.PostMapping;

@Controller
@RequestMapping("/login")
public class LoginController {
	private final LoginService loginService;

	public LoginController(LoginService loginService) {
		this.loginService = loginService;
	}

	@GetMapping
	public String login() {
		return "login";
	}

	@GetMapping("/findIdByEmail")
	public String showfindIdByEmail() {
		return "findIdByEmail";
	}

	@PostMapping("/findIdByEmail")
	public String findIdByEmail(@RequestParam("email") String email, Model model) {
		List<String> foundId = loginService.findIdByEmail(email.trim());
		model.addAttribute("foundId", foundId);

		return "findIdByEmail";
	}
}
