package com.flow.coretime.global;

import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalControllerAdvice {

        @ModelAttribute
        public void addAttributes(Model model) {
                // Spring Security를 사용 중이라면 SecurityContext에서 정보를 가져옵니다.
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();

                if (auth != null && auth.isAuthenticated() && !(auth instanceof AnonymousAuthenticationToken)) {
                        // JSP에서 사용할 변수명과 일치하게 데이터를 담습니다.
                        model.addAttribute("currentUserId", auth.getName());
                        model.addAttribute("currentUserAuthority",
                                        auth.getAuthorities().stream().findFirst().get().getAuthority().trim());
                }
        }
}
