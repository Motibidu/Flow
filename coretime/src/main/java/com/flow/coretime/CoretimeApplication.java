package com.flow.coretime;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan({"com.flow.coretime.users.mapper" , "com.flow.coretime.board.mapper" , "com.flow.coretime.elecApproval.mapper"})

public class CoretimeApplication {

	public static void main(String[] args) {
		SpringApplication.run(CoretimeApplication.class, args);
	}

}
