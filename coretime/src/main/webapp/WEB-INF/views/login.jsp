<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
<link rel="stylesheet" href='/resources/css/login.css' type="text/css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
</head>
<body>
    <img class= "login__logo" src= "/resources/images/FlowLogo.png"/>
    <form id= "login-form" action="<c:url value='/doLogin'/>" method="post">
    	<%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> --%>
        <div class="login-form__group form-floating mb-3">
            <input type="text" class="form-control" name="username" placeholder="">
            <label for="username">아이디</label>
        </div>

        <div class="login-form__group form-floating mb-3"> 
            <input type="password" class="form-control" name="password" placeholder="">
            <label for="password">비밀번호</label>
        </div>

        <div class="login-form__button-group"> 
            <button type="submit" class="login-form__button btn btn-primary btn-lg">로그인</button>
            <a href="/login/findIdByEmail" class="login-form__button btn btn-primary btn-lg">아이디 찾기</a>
            <c:if test="${param.error != null}">
            <p class="login-form__error-message">아이디 또는 비밀번호가 틀렸습니다.</p>
        </c:if>
        </div>
        
    </form>
</body>
</html>