package com.flow.coretime.home;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class HomeController {
	@GetMapping
	public String home(@AuthenticationPrincipal UserDetails userDetails, Model model) {
		model.addAttribute("currentUserId", userDetails.getUsername());
		model.addAttribute("currentUserAuthority",
				userDetails.getAuthorities().stream().findFirst().get().getAuthority().trim());

		return "home";
	}
}
