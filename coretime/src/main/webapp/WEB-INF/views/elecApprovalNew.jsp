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
<title>휴가신청</title>
<link rel="stylesheet" href='/resources/css/vacationRequestForm.css' type="text/css">
</head>
<body>
        <div class="container">
        <h1>휴가 신청서</h1>
        <form id="vacationForm" action= "/elecApproval/new" method= "post">
            <div class="form-group">
                <label for="applicantName">신청자:</label>
                <input type="text" id="applicantName" name="applicantName" value= "${currentUserName}" readonly>
            </div>

            <div class="form-group">
                <label for="department">부서:</label>
                <input type="text" id="department" name="department" value="${currentUserDepartment}" readonly>
            </div>

            <div class="form-group">
                <label for="vacationType">휴가 종류:</label>
                <select id="vacationType" name="vacationType" required>
                    <option value="">선택하세요</option>
                    <option value="연차">연차</option>
                    <option value="병가">병가</option>
                    <option value="경조사">경조사</option>
                    <option value="출산/육아">출산/육아</option>
                    <option value="기타">기타</option>
                </select>
            </div>

            <div class="form-group">
                <label for="startDate">시작일:</label>
                <input type="date" id="startDate" name="startDate" required>
            </div>

            <div class="form-group">
                <label for="endDate">종료일:</label>
                <input type="date" id="endDate" name="endDate" required>
            </div>

            <div class="form-group">
                <label for="reason">사유:</label>
                <textarea id="reason" name="reason" rows="5" placeholder="상세한 휴가 사유를 입력해주세요." required></textarea>
            </div>

            <div class="form-group">
                <label for="contactInfo">비상 연락처:</label>
                <input type="tel" id="contactInfo" name="contactInfo" placeholder="예: 010-1234-5678" pattern="[0-9]{3}-[0-9]{4}-[0-9]{4}"/>
            </div>

            <input type="hidden" id="jsonContent" name="jsonContent">
            <input type="hidden" name="docType" value="VACATION_REQUEST">
            
            <div class="form-actions">
                <button type="submit" class="submit-button" onclick= "prepareAndSubmit(event)">신청</button>
                <button type="button" class="cancel-button" onclick="history.back()">취소</button>
            </div>
            
        </form>
    </div>
    <script>
        function prepareAndSubmit(event) {
            event.preventDefault(); // 기본 폼 제출 동작 방지

            const vacationData = {
                applicantName: document.getElementById('applicantName').value,
                department: document.getElementById('department').value,
                vacationType: document.getElementById('vacationType').value,
                startDate: document.getElementById('startDate').value,
                endDate: document.getElementById('endDate').value,
                reason: document.getElementById('reason').value,
                contactInfo: document.getElementById('contactInfo').value
            };
            console.log("vacationData: ", vacationData);

            // JavaScript 객체를 JSON 문자열로 변환하여 hidden 필드에 할당
            document.getElementById('jsonContent').value = JSON.stringify(vacationData);

            // 폼을 수동으로 제출
            document.getElementById('vacationForm').submit();
        }
    </script>
</body>
</html>