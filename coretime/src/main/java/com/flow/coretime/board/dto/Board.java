package com.flow.coretime.board.dto;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Board {
	
	private Long id;

	private String author;
	
	private String email;
	
	private String departmentName;
	
	private String title;
	
	private String content;
	
	private int viewCount;
	
	private LocalDateTime createdAt;
	
	private LocalDateTime updatedAt;
	
	private String boardType;
	
	private String role;
	
	
}
