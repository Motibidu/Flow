<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${empty document ? '휴가 신청' : '휴가 신청서 재기안'}</title>
<link rel="stylesheet" href='/resources/css/vacationRequestForm.css' type="text/css">
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
</head>
<body>
    <div class="container">
        <h1>${empty document ? '휴가 신청서' : '휴가 신청서 재기안'}</h1>
        
        <form id="vacationForm" action="${empty document ? '/elecApproval/new' : '/elecApproval/redraft/'.concat(document.docId)}" method="post">
            
            <div class="form-group">
                <label for="title">문서 제목:</label>
                <input type="text" id="title" name="title" value="${empty document ? '휴가 신청서_'.concat(currentUserName) : document.title}" required>
            </div>

            <div class="form-group">
                <label for="applicantName">신청자:</label>
                <input type="text" id="applicantName" name="applicantName" value="${empty document ? currentUserName : document.initiatorName}" readonly>
            </div>

            <div class="form-group">
                <label for="department">부서:</label>
                <input type="text" id="department" name="department" value="${empty document ? currentUserDepartment : document.initiatorDepartment}" readonly>
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
            <input type="hidden" name="status" value="${document.getStatus()}">
            
            <div class="form-actions">
                <button type="submit" class="submit-button" onclick="prepareAndSubmit(event)">
                    ${empty document ? '신청' : '재상신'}
                </button>
                <button type="button" class="cancel-button" onclick="history.back()">취소</button>
            </div>
        </form>
        <c:if test="${not empty error}">
            <div class="alert alert-danger" style="color: red; border: 1px solid red; padding: 10px; margin-bottom: 20px;">
                ${error}
            </div>
    </c:if>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 수정 모드일 때 JSON 데이터를 파싱하여 필드에 채움
            const existingJson = '<c:out value="${document.jsonContent}" escapeXml="false"/>';
            
            if (existingJson && existingJson.trim() !== "") {
                try {
                    const data = JSON.parse(existingJson);
                    document.getElementById('vacationType').value = data.vacationType || '';
                    document.getElementById('startDate').value = data.startDate || '';
                    document.getElementById('endDate').value = data.endDate || '';
                    document.getElementById('reason').value = data.reason || '';
                    document.getElementById('contactInfo').value = data.contactInfo || '';
                } catch (e) {
                    console.error("기존 데이터 로딩 실패:", e);
                }
            }
        });

        function prepareAndSubmit(event) {
            event.preventDefault();

            const vacationData = {
                applicantName: document.getElementById('applicantName').value,
                department: document.getElementById('department').value,
                vacationType: document.getElementById('vacationType').value,
                startDate: document.getElementById('startDate').value,
                endDate: document.getElementById('endDate').value,
                reason: document.getElementById('reason').value,
                contactInfo: document.getElementById('contactInfo').value
            };

            // JSON 변환 후 hidden 필드에 할당
            document.getElementById('jsonContent').value = JSON.stringify(vacationData);
            document.getElementById('vacationForm').submit();
        }
    </script>
</body>
</html>