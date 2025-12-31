package com.flow.coretime.users.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.flow.coretime.users.mapper.LoginMapper;

@Service
public class LoginService {
        LoginMapper loginMapper;

        public LoginService(LoginMapper loginMapper)
        {
                this.loginMapper= loginMapper;
        }

        public List<String> findIdByEmail(String email){
                return loginMapper.findIdByEmail(email);
        }
}
