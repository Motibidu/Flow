package com.flow.coretime;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
@MapperScan({ "com.flow.coretime.users.mapper", "com.flow.coretime.board.mapper",
		"com.flow.coretime.elecApproval.mapper", "com.flow.coretime.notification.mapper" })

public class CoretimeApplication {

	public static void main(String[] args) {
		SpringApplication.run(CoretimeApplication.class, args);
	}

}
