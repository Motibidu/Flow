<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
        .header {
		width: 100%;
		height: 80px; /* 고정 높이 */
		display: flex;
		align-items: center; /* 수직 중앙 정렬 */
		background-color: #f8f9fa; /* 밝은 회색 배경 */
		padding: 0 30px; /* 좌우 패딩 추가 */
	}

	.header__logout{
		margin-left: auto;
		margin-right: 50px;		
	}

	.header__logo{
		max-width: 200px;
	}

	.user-info {
		font-weight: bold; /* 굵은 글씨 */
		color: #343a40; /* 어두운 글씨색 */
		font-size: 1.1em; /* 약간 크게 */
		margin-right: 15px;
	}
</style>
</head>
<body>
        <header class= "header">
		<a href="/" class="header__logo-link">
			<img class= "header__logo" src= "/resources/images/FlowLogo.png"/>
		</a>
		<form class= "header__logout" action="/logout" method="post">
			<%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /> --%>
			<span class="user-info">
                		아이디: ${currentUserId} 권한: ${currentUserAuthority}
            		</span>
			<button class= "btn btn-secondary"type="submit">로그아웃</button>
		</form>
	</header>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
</body>
</html>