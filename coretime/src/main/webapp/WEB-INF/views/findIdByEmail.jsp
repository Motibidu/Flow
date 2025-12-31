<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<%-- <meta name="_csrf_token" content="${_csrf.token}" />
<meta name="_csrf_header" content="${_csrf.headerName}" /> --%>
<title>아이디 찾기</title>
<style>
    body{
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
    }
    .logo {
        max-width: 200px;
    }
    
    .findId__button{
        height: 50px;
        width: 400px;
        margin-bottom: 15px;
    }
    
    .foundIdResult{
        padding-top: 30px;
        width: 400px;
        text-align: left;
    }
</style>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
</head>
<body>  
        <a class= "logo" href="/login" class="findId__button btn btn-primary btn-lg">
            <img class= "logo" src= "/resources/images/FlowLogo.png"/>
        </a>
        <form action= "/login/findIdByEmail" method= "post" class= "findIdForm">
                <div class="findIdForm__group form-floating mb-3"> 
                    <input type="email" class="form-control" name="email" placeholder="">
                    <label for="email">이메일을 입력하세요</label>
                </div>
                <button type= "submit" class="findId__button btn btn-primary btn-lg">아이디 찾기</button>
        </form>
        <a href="/login" class="findId__button btn btn-primary btn-lg">로그인으로 이동</a>
        


        <div class="foundIdResult">
            <c:if test="${not empty foundId}">
                <h3>찾은 아이디:</h3>
                <ul>
                    <c:forEach var="id" items="${foundId}">
                        <li>${id}</li>
                    </c:forEach>
                </ul>
            </c:if>
            <c:if test="${empty foundId && param.email != null}">
                <p>해당 이메일로 등록된 아이디가 없습니다.</p>
            </c:if>
        </div>

</body>
</html>