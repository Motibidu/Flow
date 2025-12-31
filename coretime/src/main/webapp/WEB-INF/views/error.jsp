<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>오류 발생</title>
</head>
<body>
    <h1>오류가 발생했습니다!</h1>
    <p>
        죄송합니다. 요청하신 작업을 처리하는 중 문제가 발생했습니다.<br>
        자세한 내용은 관리자에게 문의해 주세요.
    </p>
    <%-- 컨트롤러에서 전달받은 오류 메시지를 표시합니다 (선택 사항) --%>
    <p style="color: red;">${errorMessage}</p>
    <br>
    <a href="/">홈으로 돌아가기</a>
</body>
</html>