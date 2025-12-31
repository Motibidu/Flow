<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시판</title>
    <!-- 요청하신 DataTables CSS (디자인 요소로만 사용) -->
    <link href="https://cdn.datatables.net/2.0.8/css/dataTables.dataTables.min.css" rel="stylesheet">
    
    <!-- 수동으로 작성한 스타일 (Bootstrap 대체) -->
    <style>
        /* leftNav.jsp의 스타일을 여기에 직접 포함 */
        .left-nav { width: 200px; background-color: #f8f9fa; padding: 20px; box-shadow: 2px 0 5px rgba(0,0,0,0.1); flex-shrink: 0; min-height: calc(100vh - 56px); }
        .left-nav ul { list-style: none; padding: 0; margin: 0; }
        .left-nav li { margin-bottom: 10px; }
        .left-nav a { text-decoration: none; color: #007bff; font-weight: 500; display: block; padding: 8px 12px; border-radius: 4px; transition: background-color 0.2s ease, color 0.2s ease; }
        .left-nav a:hover { background-color: #e9ecef; color: #0056b3; }
        .left-nav a.active { background-color: #007bff; color: white; font-weight: bold; }
        
        /* 전체 레이아웃 */
        .content { display: flex; }
        .main-content { flex-grow: 1; padding: 20px 30px; }

        /* 이 페이지 전용 스타일 */
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .table { width: 100%; border-collapse: collapse; text-align: center; }
        .table th, .table td { border: 1px solid #ddd; padding: 10px; }
        .table thead th { background-color: #f2f2f2; }
        .table tbody tr:hover { background-color: #f5f5f5; cursor: pointer; }
        
        /* ======================= 이 부분이 수정되었습니다 ======================= */
        /* .notice-row 스타일을 삭제하여 노란색 배경 제거 */
        .badge { display: inline-block; padding: .35em .65em; font-size: .75em; font-weight: 700; line-height: 1; color: #212529; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: .25rem; background-color: #ffc107; }
        /* ====================================================================== */
        
        .search-area, .pagination-area { display: flex; justify-content: center; margin-top: 20px; gap: 8px; }
        .pagination { display: flex; list-style: none; padding: 0; gap: 5px; }
        .pagination a { padding: 8px 12px; border: 1px solid #ddd; text-decoration: none; color: #007bff; }
        .pagination .active a { background-color: #007bff; color: white; border-color: #007bff; }
        .btn { padding: 8px 16px; border-radius: 4px; cursor: pointer; text-decoration: none; border: 1px solid #007bff; background-color: #007bff; color: white; }
        .form-select, .form-control { padding: 8px; border: 1px solid #ccc; border-radius: 4px; }
        .alert { padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: 4px; }
        .alert-success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
        .alert-danger { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
    </style>
</head>
<body>
    <div id="header"><%@ include file="header.jsp" %></div>
    <div class="content">
        <div id="nav"><%@ include file="leftNav.jsp" %></div>
        <main class="main-content">
            <div class="page-header">
                <h2>게시판</h2>
                <a href="/boards/write" class="btn">글쓰기</a>
            </div>

            <c:if test="${not empty successMessage}"><div class="alert alert-success">${successMessage}</div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger">${errorMessage}</div></c:if>

            <table class="table">
                <thead>
                    <tr>
                        <th style="width: 8%;">번호</th><th style="width: 10%;">구분</th><th>제목</th><th style="width: 15%;">작성자</th><th style="width: 15%;">작성일</th><th style="width: 10%;">조회수</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty boardList}"><tr><td colspan="6">게시글이 없습니다.</td></tr></c:when>
                        <c:otherwise>
                            <c:forEach items="${boardList}" var="board">
                                <!-- 이제 class에 .notice-row가 붙어도 아무 효과가 없습니다. -->
                                <tr class="${board.boardType == 'NOTICE' ? 'notice-row' : ''}" onclick="location.href='/boards/${board.id}'">
                                    <td>${board.id}</td>
                                    <td>
                                        <c:if test="${board.boardType == 'NOTICE'}"><span class="badge">공지</span></c:if>
                                        <c:if test="${board.boardType != 'NOTICE'}"><span>일반</span></c:if>
                                    </td>
                                    <td style="text-align: left;">${board.title}</td>
                                    <td>${board.author}</td>
                                    <td><c:if test="${not empty board.createdAt}">${board.createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))}</c:if></td>
                                    <td>${board.viewCount}</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>

            <div class="search-area">
                <form action="/boards" method="get" style="display: flex; gap: 8px;">
                    <select name="searchType" class="form-select">
                        <option value="title" ${searchType == 'title' ? 'selected' : ''}>제목</option>
                        <option value="content" ${searchType == 'content' ? 'selected' : ''}>내용</option>
                        <option value="author" ${searchType == 'author' ? 'selected' : ''}>작성자</option>
                    </select>
                    <input type="text" name="keyword" class="form-control" style="width: 300px;" value="${keyword}" placeholder="검색어를 입력하세요">
                    <button type="submit" class="btn">검색</button>
                </form>
            </div>

            <div class="pagination-area">
                <ul class="pagination">
                    <c:if test="${totalPages > 0}">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="${i == currentPage ? 'active' : ''}"><a href="/boards?page=${i}&searchType=${searchType}&keyword=${keyword}">${i}</a></li>
                        </c:forEach>
                    </c:if>
                </ul>
            </nav>
        </main>
    </div>
</body>
</html>