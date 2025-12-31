<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 수정</title>
    <style>
        .left-nav { width: 200px; background-color: #f8f9fa; padding: 20px; box-shadow: 2px 0 5px rgba(0,0,0,0.1); flex-shrink: 0; min-height: calc(100vh - 56px); }
        .left-nav ul { list-style: none; padding: 0; margin: 0; }
        .left-nav li { margin-bottom: 10px; }
        .left-nav a { text-decoration: none; color: #007bff; font-weight: 500; display: block; padding: 8px 12px; border-radius: 4px; transition: background-color 0.2s ease, color 0.2s ease; }
        .left-nav a:hover { background-color: #e9ecef; color: #0056b3; }
        .left-nav a.active { background-color: #007bff; color: white; font-weight: bold; }
        .content { display: flex; }
        .main-content { flex-grow: 1; padding: 20px 30px; }
        .form-container { max-width: 800px; margin: auto; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        .form-control[readonly] { background-color: #e9ecef; }
        textarea.form-control { height: 300px; resize: vertical; }
        .btn { padding: 10px 20px; border-radius: 4px; cursor: pointer; text-decoration: none; border: 1px solid; }
        .btn-primary { background-color: #007bff; color: white; border-color: #007bff; }
        .btn-secondary { background-color: #6c757d; color: white; border-color: #6c757d; }
    </style>
</head>
<body>
    <div id="header"><%@ include file="header.jsp" %></div>
    <div class="content">
        <div id="nav"><%@ include file="leftNav.jsp" %></div>
        <main class="main-content">
            <div class="form-container">
                <h2 style="text-align: center; margin-bottom: 30px;">게시글 수정</h2>
                <form:form modelAttribute="board" action="/boards/${board.id}/edit" method="post">
                    <div class="form-group">
                        <label>게시판 종류</label>
                        <input type="text" class="form-control" value="${board.boardType == 'NOTICE' ? '공지' : '일반'}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="title">제목</label>
                        <form:input path="title" id="title" cssClass="form-control" required="true" />
                    </div>
                    <div class="form-group">
                        <label for="content">내용</label>
                        <form:textarea path="content" id="content" cssClass="form-control" required="true" />
                    </div>
                    <div style="text-align: center; margin-top: 20px;">
                        <button type="submit" class="btn btn-primary">수정 완료</button>
                        <a href="/boards/${board.id}" class="btn btn-secondary">취소</a>
                    </div>
                </form:form>
            </div>
        </main>
    </div>
</body>
</html>