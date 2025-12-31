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
<title>사용자 정보 수정</title>

<style>
.main-content {
	width: auto;
	display: flex;
}

.user-edit {
	padding: 20px;
	border-radius: 8px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	max-width: 600px;
	margin: 20px 0;
}

.form-group {
	margin-bottom: 15px;
}

.form-group label {
	display: block;
	margin-bottom: 5px;
	font-weight: bold;
}

.form-group input[type="text"],
.form-group input[type="email"],
.form-group input[type="date"],
.form-group select {
	width: calc(100% - 18px); /* 패딩, 보더 포함 너비 조정 */
	padding: 8px;
	border: 1px solid #ddd;
	border-radius: 4px;
	box-sizing: border-box;
}

.form-actions {
	text-align: right;
	margin-top: 20px;
}

.form-actions button {
	padding: 10px 15px;
	border: none;
	border-radius: 5px;
	cursor: pointer;
	font-size: 16px;
	margin-left: 10px;
}

.form-actions .submit-btn {
	background-color: #007bff;
	color: white;
}

.form-actions .cancel-btn {
	background-color: #6c757d;
	color: white;
}

/*========================================================*/

.user-edit{
	margin: 0 auto;
}
.user-edit__form-group{
	display: flex;
	align-items: center;
	justify-content: center;
}
.profile-image-section__preview{
	max-width: 300px;
	min-width: 100px;
}
.profile-image-section__input{
	display: none;
}
.profile-image-section__edit-button img{
	text-align: center;
	width: 30px;
	height: auto;
}
.profile-image-section__edit-button img:hover{
	background-color: #e0e0e0;
	cursor: pointer;
}

</style>
<script>
	document.addEventListener('DOMContentLoaded', function(){
		const profileImageInput = document.getElementById('profileImage');
		const profileImagePreview = document.getElementById('profileImagePreview');
		if (profileImageInput && profileImagePreview) {
			profileImageInput.addEventListener('change', function(event) {
				if (event.target.files && event.target.files[0]) {
					const reader = new FileReader();
					reader.onload = function(e) {
						profileImagePreview.src = e.target.result;
					};
					reader.readAsDataURL(profileImageInput.files[0]);
				} 
			});
		}
	})
</script>
</head>
<body>
	<div id="header">
		<%@ include file="header.jsp"%>
	</div>

	<div class="main-content">
		<div id="nav">
			<%@ include file="leftNav.jsp"%>
		</div>
		
		

		<div class="user-edit">
			<h1>사용자 정보 수정</h1>
			<form:form modelAttribute="user" method="post" action="/users/edit?existingId=${user.id}" enctype= "multipart/form-data">
				<div class="user-edit__form-group profile-image-section">
					<img class= "profile-image-section__preview" id= "profileImagePreview" src= "${user.profileImagePath}" alt="프로필 이미지 미리보기" />
					<input class= "profile-image-section__input"type="file" id="profileImage" name="profileImage" accept="image/*"/>
					<label class="profile-image-section__edit-button" for="profileImage" >
						<img src="/resources/images/pencil.svg"/>
					</label>
				</div>
				<div class="form-group">
					<label for="name">이름:</label>
					<form:input path="name" id="name"/>
				</div>
				<div class="form-group">
					<label for="id">아이디:</label>
					<form:input path="id" id="id"/>
				</div>
				<%-- <div class="form-group">
					<label for="password">비밀번호:</label>
					<form:input type= "password" path="password" id="password" placeholder="변경할 비밀번호를 입력하세요"/>
				</div> --%>
				<div class="form-group">
					<label for="email">이메일:</label>
					<form:input type="email" path="email"  id="email"/>
				</div>
				
				<div class="form-group">
					<label for="tel">전화번호:</label>
					<form:input path="tel" id="tel"/>
				</div>
				<div class="form-group">
					<label for="rank">직위:</label>
					<form:select path="rank" id="rankSelect">
						<form:option value="">선택</form:option>
						<form:option value="사원">사원</form:option>
						<form:option value="대리">대리</form:option>
						<form:option value="과장">과장</form:option>
						<form:option value="차장">차장</form:option>
						<form:option value="부장">부장</form:option>
				</form:select>
				</div>
				<div class="form-group">
					<label for="department">부서:</label>
					<form:select path="department" id="departmentSelect">
						<form:option value="">선택</form:option>
						<form:option value="개발팀">개발팀</form:option>
						<form:option value="영업팀">영업팀</form:option>
						<form:option value="마케팅팀">마케팅팀</form:option>
						<form:option value="인사팀">인사팀</form:option>
						<form:option value="회계팀">회계팀</form:option>
					</form:select>
				</div>
				<div class="form-actions">
					<button type="submit" class="submit-btn">수정 완료</button>
					<button type="button" class="cancel-btn" onclick="history.back()">취소</button>
				</div>
			</form:form>
		</div>
	</div>
</body>
</html>