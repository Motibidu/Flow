<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${board.title}</title>
    <style>
        .left-nav { width: 200px; background-color: #f8f9fa; padding: 20px; box-shadow: 2px 0 5px rgba(0,0,0,0.1); flex-shrink: 0; min-height: calc(100vh - 56px); }
        .left-nav ul { list-style: none; padding: 0; margin: 0; }
        .left-nav li { margin-bottom: 10px; }
        .left-nav a { text-decoration: none; color: #007bff; font-weight: 500; display: block; padding: 8px 12px; border-radius: 4px; transition: background-color 0.2s ease, color 0.2s ease; }
        .left-nav a:hover { background-color: #e9ecef; color: #0056b3; }
        .left-nav a.active { background-color: #007bff; color: white; font-weight: bold; }
        .content { display: flex; }
        .main-content { flex-grow: 1; padding: 20px 30px; }
        .board-container { border: 1px solid #ddd; padding: 20px; border-radius: 5px; }
        .board-header { padding-bottom: 10px; border-bottom: 1px solid #eee; margin-bottom: 20px; }
        .board-header h2 { margin: 0; }
        .board-meta { font-size: 0.9em; color: #666; }
        .board-content { min-height: 250px; line-height: 1.6; white-space: pre-wrap; }
        .button-group { text-align: right; margin-top: 20px; }
        .btn { display: inline-block; padding: 8px 16px; border-radius: 4px; cursor: pointer; text-decoration: none; margin-left: 5px; }
        .btn-primary { border: 1px solid #007bff; background-color: #007bff; color: white; }
        .btn-secondary { border: 1px solid #6c757d; background-color: #6c757d; color: white; }
        .btn-danger { border: 1px solid #dc3545; background-color: #dc3545; color: white; }
    </style>
</head>
<body>
    <div id="header"><%@ include file="header.jsp" %></div>
    <div class="content">
        <div id="nav"><%@ include file="leftNav.jsp" %></div>
        <main class="main-content">
            <h2>게시글 상세</h2>
            <div class="board-container">
                <div class="board-header">
                    <h2><c:out value="${board.title}" /></h2>
                    <div class="board-meta">
                        <strong>작성자:</strong> ${board.author} | 
                        <c:if test="${not empty board.createdAt}"><strong>작성일:</strong> ${board.createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))} | </c:if>
                        <strong>조회수:</strong> ${board.viewCount}
                    </div>
                </div>
                <div class="board-content">${board.content}</div>
            </div>
            <div class="button-group">
                <a href="/boards" class="btn btn-secondary">목록</a>
                <c:if test="${isOwner}">
                    <a href="/boards/${board.id}/edit" class="btn btn-primary">수정</a>
                    <form action="/boards/${board.id}/delete" method="post" style="display: inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                        <button type="submit" class="btn btn-danger">삭제</button>
                    </form>
                </c:if>
            </div>
        </main>
    </div>
</body>
</html>