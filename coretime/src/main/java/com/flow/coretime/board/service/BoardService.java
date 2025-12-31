package com.flow.coretime.board.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.flow.coretime.board.dto.Board;
import com.flow.coretime.board.mapper.BoardMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BoardService {

	private final BoardMapper boardMapper;

	//게시글 생성
	@Transactional
	public void createBoard(Board board) {		
		boardMapper.save(board);
	}
	
	//게시글 목록 조회
	public List<Board> getBoardList(Map<String, Object> params) {
		return boardMapper.findWithPaging(params);
	}
	
	//게시글 총 개수 조회
	public int getBoardCount(Map<String, Object> searchParams) {
		return boardMapper.count(searchParams);
	}
	
	//게시글 상세 조회 (+ 조회수 증가)
	@Transactional
	public Board getBoardDetail(Long id) {
		boardMapper.updateViewCount(id);
		return boardMapper.findById(id);
	}
	
	//게시글 조회(수정 페이지 이동할때는 조회수 증가하면 안되므로 조회수 증가 로직 없음.)
	public Board getBoardByIdForUpdate(Long id) {
		return boardMapper.findById(id);
	}
	
	//게시글 수정
	@Transactional
	public void updateBoard(Board board) {
		boardMapper.update(board);
	}
	
	//게시글 삭제
	public void deleteBoard(Long id) {
		boardMapper.deleteById(id);
	}
}
