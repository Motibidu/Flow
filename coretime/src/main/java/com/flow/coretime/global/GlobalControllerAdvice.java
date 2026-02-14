package com.flow.coretime.global;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

import com.flow.coretime.global.exception.UnauthorizedException;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@ControllerAdvice("com.flow.coretime")
public class GlobalControllerAdvice {

    @ExceptionHandler(UnauthorizedException.class)
    public ModelAndView handleUnauthorizedException(UnauthorizedException e) {
        log.warn("권한이 없는 사용자의 접근: {}", e.getMessage());
        ModelAndView mav = new ModelAndView();
        mav.addObject("errorMessage", e.getMessage());
        mav.setViewName("error/unauthorized");
        return mav;
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ModelAndView handleUnauthorizedException(AccessDeniedException e) {
        log.warn("권한이 없는 사용자의 접근: {}", e.getMessage());
        ModelAndView mav = new ModelAndView();
        mav.addObject("errorMessage", e.getMessage());
        mav.setViewName("error/unauthorized");
        return mav;
    }
}