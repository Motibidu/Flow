<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>신규 유저 생성</title>
	<link rel="stylesheet" href='/resources/css/userForm.css' type="text/css">
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
	<style>
		.content{
			display:flex;
		}
	</style>

	<script>
		document.addEventListener('DOMContentLoaded', function() {
			// 이름 (name) 필드
			const nameInput = document.getElementById('name');
			const nameError = document.getElementById('nameError');
			if (nameInput && nameError) {
				nameInput.addEventListener('input', function() {
					if (nameError.style.display !== 'none') {
						nameError.style.display = 'none';
					}
			});
			}

			// 아이디 (id) 필드
			const idInput = document.getElementById('id');
			const idError = document.getElementById('idError');
			if (idInput && idError) {
				idInput.addEventListener('input', function() {
					if (idError.style.display !== 'none') {
						idError.style.display = 'none';
					}
				});
			}

			// 비밀번호 (password) 필드
			const passwordInput = document.getElementById('password');
			const passwordError = document.getElementById('passwordError');
			if (passwordInput && passwordError) {
				passwordInput.addEventListener('input', function() {
					if (passwordError.style.display !== 'none') {
						passwordError.style.display = 'none';
					}
				});
			}

			// 비밀번호 확인 (confirmPassword) 필드
			const confirmPasswordInput = document.getElementById('confirmPassword');
			const confirmPasswordError = document.getElementById('confirmPasswordError');
			if (confirmPasswordInput && confirmPasswordError) {
				confirmPasswordInput.addEventListener('input', function() {
					if (confirmPasswordError.style.display !== 'none') {
						confirmPasswordError.style.display = 'none';
					}
			});
			}

			// 이메일 (email) 필드
			const emailInput = document.getElementById('email');
			const emailError = document.getElementById('emailError');
			if (emailInput && emailError) {
				emailInput.addEventListener('input', function() {
					if (emailError.style.display !== 'none') {
						emailError.style.display = 'none';
					}
			});
			}

			// 전화번호 (tel) 필드
			const telInput = document.getElementById('tel');
			const telError = document.getElementById('telError');
			if (telInput && telError) {
				telInput.addEventListener('input', function() {
					if (telError.style.display !== 'none') {
						telError.style.display = 'none';
					}
			});
			}

			// 직위 (rank) 필드 - select는 'change' 이벤트를 사용
			const rankSelect = document.getElementById('rankSelect');
			const rankError = document.getElementById('rankError');
			if (rankSelect && rankError) {
				rankSelect.addEventListener('change', function() {
					if (rankError.style.display !== 'none') {
						rankError.style.display = 'none';
					}
			});
			}

			// 부서 (department) 필드 - select는 'change' 이벤트를 사용
			const departmentSelect = document.getElementById('departmentSelect');
			const departmentError = document.getElementById('departmentError');
			if (departmentSelect && departmentError) {
				departmentSelect.addEventListener('change', function() {
					if (departmentError.style.display !== 'none') {
						departmentError.style.display = 'none';
					}
				});
			}

			// 생년월일 (birth) 필드
			const birthInput = document.getElementById('birth');
			const birthError = document.getElementById('birthError');
			if (birthInput && birthError) {
				birthInput.addEventListener('input', function() {
					if (birthError.style.display !== 'none') {
					birthError.style.display = 'none';
					}
				});
			}

			const profileImageInput = document.getElementById('profileImage');
			const profileImagePreview = document.getElementById('profileImagePreview');
			const profileImageError = document.getElementById('profileImageError');
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
		});
		

		
		function validateForm(event) {
			const nameInput = document.getElementById("name");
			if (nameInput.value.trim() === "") {
				nameInput.focus();
			}

			const idInput = document.getElementById("id");
			if (idInput.value.trim() === "") {
				idInput.focus();
			}

			const passwordInput = document.getElementById("password");
			if (passwordInput.value.trim() === "") {
				passwordInput.focus();
			}

			// 비밀번호 확인
			const confirmPasswordInput = document.getElementById("confirmPassword");
			if (confirmPasswordInput.value.trim() === "") {
				confirmPasswordInput.focus();

			} else if (passwordInput.value !== confirmPasswordInput.value) {
				confirmPasswordInput.focus();
			}

			// 이메일
			const emailInput = document.getElementById("email");
			if (emailInput.value.trim() === "") {
				emailInput.focus();
			} else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailInput.value)) { // 간단한 이메일 형식 검사
				emailInput.focus();
			}

			// 전화번호
			const telInput = document.getElementById("tel");
			if (telInput.value.trim() === "") {
				telInput.focus();
			} else if (!/^(01[016789])-([0-9]{3,4})-([0-9]{4})$/
					.test(telInput.value)) { // 전화번호 형식 검사
				telInput.focus();
			}

			// 직위
			const rankSelect = document.getElementById("rankSelect");
			if (rankSelect.value === "") {
				rankSelect.focus();
			}

			// 부서
			const departmentSelect = document.getElementById("departmentSelect");
			if (departmentSelect.value === "") {
				departmentSelect.focus();
			}

			// 생년월일 (간단한 필수 여부만)
			const birthInput = document.getElementById("birth");
			if (birthInput.value.trim() === "") {
				birthInput.focus();
			}
		}
	</script>
</head>
<body>
	<div id="header">
                <%@ include file="header.jsp" %>
	</div>
	<div class= "content">
                <div id="nav">
                    <%@ include file="leftNav.jsp" %>
                </div>
		<div class="user-create">
			<h2 class="user-create__title">신규 유저 생성</h2>
			<form:form modelAttribute="user" method="post" action="/users/insert"
			onsubmit="return validateForm(event)" enctype="multipart/form-data" class="user-create__form">
			<div class="user-create__form-group">
				<img  src= "/resources/images/person.svg" id= "profileImagePreview" alt="프로필 이미지 미리보기" class="user-create__image-preview" />
			</div>
			<div class="user-create__form-group">
				<label for="profileImage" class="user-create__label">프로필 사진:</label>
				<input type="file" id="profileImage" name="profileImage" accept="image/*" class="user-create__input user-create__input--file"/>
			</div>
			<div class="user-create__form-group">
				<label for="name" class="user-create__label">이름 (한글):</label>
				<form:input path="name" id="name" class="user-create__input"/>
				<form:errors path="name" cssClass="user-create__error-message" cssStyle="color: red;" id="nameError" />
			</div>

			<div class="user-create__form-group">
				<label for="id" class="user-create__label">아이디:</label>
				<form:input path="id" id="id" class="user-create__input"/>
				<form:errors path="id" cssClass="user-create__error-message" cssStyle="color: red;" id="idError" />
			</div>

			<div class="user-create__form-group">
				<label for="password" class="user-create__label">비밀번호:</label>
				<form:password path="password" id="password" class="user-create__input"/>
				<form:errors path="password" cssClass="user-create__error-message" cssStyle="color: red;" id="passwordError" />
			</div>

			<div class="user-create__form-group">
				<label for="confirmPassword" class="user-create__label">비밀번호 확인:</label>
				<form:password path="confirmPassword" id="confirmPassword" class="user-create__input"/>
				<form:errors path="confirmPassword" cssClass="user-create__error-message" cssStyle="color: red;" id="confirmPasswordError" />
			</div>

			<div class="user-create__form-group">
				<label for="email" class="user-create__label">이메일:</label>
				<form:input path="email" id="email" class="user-create__input"/>
				<form:errors path="email" cssClass="user-create__error-message" cssStyle="color: red;" id="emailError" />
			</div>

			<div class="user-create__form-group">
				<label for="tel" class="user-create__label">전화번호:</label>
				<form:input path="tel" id="tel" class="user-create__input" placeholder="010-XXXX-XXXX"/> <%-- placeholder 추가 --%>
				<form:errors path="tel" cssClass="user-create__error-message" cssStyle="color: red;" id="telError" />
			</div>

			<div class="user-create__form-group">
				<label for="rankSelect" class="user-create__label">직위:</label>
				<form:select path="rank" id="rankSelect" class="user-create__select">
				<form:option value="">선택</form:option>
				<form:option value="사원">사원</form:option>
				<form:option value="대리">대리</form:option>
				<form:option value="과장">과장</form:option>
				<form:option value="차장">차장</form:option>
				<form:option value="부장">부장</form:option>
				</form:select>
				<form:errors path="rank" cssClass="user-create__error-message" cssStyle="color: red;" id="rankError" />
			</div>

			<div class="user-create__form-group">
				<label for="departmentSelect" class="user-create__label">부서:</label>
				<form:select path="department" id="departmentSelect" class="user-create__select">
				<form:option value="">선택</form:option>
				<form:option value="개발팀">개발팀</form:option>
				<form:option value="영업팀">영업팀</form:option>
				<form:option value="마케팅팀">마케팅팀</form:option>
				<form:option value="인사팀">인사팀</form:option>
				<form:option value="회계팀">회계팀</form:option>
				</form:select>
				<form:errors path="department" cssClass="user-create__error-message" cssStyle="color: red;" id="departmentError" />
			</div>

			<div class="user-create__form-group">
				<label for="birth" class="user-create__label">생년월일:</label>
				<form:input path="birth" id="birth" type="date" class="user-create__input user-create__input--date"/>
				<form:errors path="birth" cssClass="user-create__error-message" cssStyle="color: red;" id="birthError" />
			</div>

			<div class="user-create__actions">
				<button type="submit" class="user-create__button user-create__button--primary">저장</button>
			</div>
			</form:form>
		</div>
	</div>
</body>
</html>