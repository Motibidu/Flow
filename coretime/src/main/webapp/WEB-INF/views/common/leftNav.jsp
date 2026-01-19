<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
    .left-nav {
        width: 200px;
        background-color: #f8f9fa;
        padding: 20px;
        box-shadow: 2px 0 5px rgba(0,0,0,0.1);
        min-height: 100vh; 
        box-sizing: border-box;
    }
    .left-nav ul {
        list-style: none; /* 목록 마커 제거 */
        padding: 0;
        margin: 0;
    }
    .left-nav li {
        margin-bottom: 10px;
    }
    .left-nav a {
        text-decoration: none; /* 밑줄 제거 */
        color: #007bff; /* 링크 색상 */
        font-weight: 500; /* 폰트 두께 */
        display: block; /* 링크 전체 영역 클릭 가능 */
        padding: 8px 12px;
        border-radius: 4px; /* 모서리 둥글게 */
        transition: background-color 0.2s ease, color 0.2s ease; /* 호버 효과 부드럽게 */
    }
    .left-nav a:hover {
        background-color: #e9ecef; /* 호버 시 배경색 */
        color: #0056b3; /* 호버 시 글자색 */
    }
    .left-nav a.active { /* 현재 페이지 링크 스타일 */
        background-color: #007bff;
        color: white;
        font-weight: bold;
    }
    /* 서브메뉴 스타일 */
    .left-nav .submenu {
        list-style: none;
        padding: 0;
        margin: 5px 0 0 0;
        background-color: #f1f3f5;
        border-radius: 4px;
    }
    .left-nav .submenu li {
        margin-bottom: 0;
    }
    .left-nav .submenu a {
        font-size: 14px;
        padding: 8px 10px 8px 25px; /* 들여쓰기 */
        color: #555;
    }
    .left-nav .submenu a:hover {
        background-color: #e2e6ea;
        color: #333;
    }
</style>

</head>
<body>
	<nav class="left-nav">
		<ul>
            <li><a href="/" class="${pageContext.request.requestURI eq '/WEB-INF/views/home.jsp' ? 'active' : ''}">홈</a></li>
            <li>
                <c:set var="isElecApproval" value="${fn:contains(pageContext.request.requestURI, 'elecApproval')}" />
                <a href="/elecApproval" class="${isElecApproval ? 'active' : ''}">전자 결재</a>
                <c:if test="${isElecApproval}">
                    <ul class="submenu">
                        <li><a href="/elecApproval/temp">임시 저장함</a></li>
                        <li><a href="/elecApproval/my-turn">결재차례 문서</a></li>
                        <li><a href="/elecApproval/pending-or-progress">진행중인 문서</a></li>
                        <li><a href="/elecApproval/rejected-or-recalled">반려 및 취소</a></li>
                        <li><a href="/elecApproval/approved">완료 문서</a></li>
                    </ul>
                </c:if>
            </li>
            <li><a href="/users" class="${pageContext.request.requestURI eq '/WEB-INF/views/users.jsp' ? 'active' : ''}">사용자 관리</a></li>
            <li><a href="/boards" class="${pageContext.request.requestURI eq '/WEB-INF/views/combinedList.jsp' ? 'active' : ''}">게시판</a></li>
            <li>
                <c:set var="isMyPage" value="${fn:contains(pageContext.request.requestURI, 'substitute-approvals')}" />
                <a href="/users/substitute-approvals" class="${isMyPage ? 'active' : ''}">마이페이지</a>
                <c:if test="${isMyPage}">
                    <ul class="submenu">
                        <li><a href="/users/substitute-approvals">대리 결재자 설정</a></li>
                    </ul>
                </c:if>
            </li>
        </ul>
	</nav>
</body>
</html>