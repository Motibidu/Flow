package com.flow.coretime.board.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.flow.coretime.board.dto.Board;



@Mapper
public interface BoardMapper {

	void save(Board board);
	
	Board findById(Long id);
	
	List<Board> findAll();
	
	void update(Board board);
	
	void deleteById(Long id);
	
	void updateViewCount(Long id);
	
	List<Board> findWithPaging(Map<String, Object > params);
	
	int count(Map<String , Object> searchParams);
}
