<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>휴가신청</title>
<link rel="stylesheet" href='/resources/css/vacationRequestForm.css' type="text/css">
<style>
    /* 제목 입력을 강조하기 위한 추가 스타일 */
    .title-input {
        font-size: 1.1em;
        font-weight: bold;
        border: 2px solid #007bff !important;
    }
</style>
</head>
<body>
    <div class="container">
        <h1>휴가 신청서</h1>
        <form id="vacationForm" action="/elecApproval/new" method="post">
            
            <div class="form-group">
                <label for="title">문서 제목:</label>
                <input type="text" id="title" name="title" class="title-input" required>
                <div><small style="color: #666;">* 결재 리스트에 표시될 제목입니다.</small></div>
            </div>

            <div class="form-group">
                <label for="applicantName">신청자:</label>
                <input type="text" id="applicantName" name="applicantName" value="${currentUserName}" readonly>
            </div>

            <div class="form-group">
                <label for="department">부서:</label>
                <input type="text" id="department" name="department" value="${currentUserDepartment}" readonly>
            </div>

            <div class="form-group">
                <label for="vacationType">휴가 종류:</label>
                <select id="vacationType" name="vacationType" onchange="autoGenerateTitle()" required>
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
                <input type="date" id="startDate" name="startDate" onchange="autoGenerateTitle()" required>
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
                <button type="submit" class="submit-button" onclick="prepareAndSubmit(event)">신청</button>
                <button type="button" class="cancel-button" onclick="history.back()">취소</button>
            </div>
            
        </form>
    </div>

    <script>
        /**
         * 사용자가 휴가 종류나 시작일을 선택하면 제목을 자동으로 만들어주는 보조 함수
         */
        function autoGenerateTitle() {
            const titleInput = document.getElementById('title');
            
            // 이미 사용자가 직접 수정한 경우는 건드리지 않음
            if (titleInput.value !== "" && !titleInput.dataset.auto) return;

            const type = document.getElementById('vacationType').value;
            const name = document.getElementById('applicantName').value;
            const start = document.getElementById('startDate').value;

            if (type && name) {
                const generated = `[\${type}] \${name} 휴가 신청 (\${start})`;
                titleInput.value = generated;
                titleInput.dataset.auto = "true"; // 시스템이 만든 제목임을 표시
            }
        }

        /**
         * 제출 전 데이터 정리
         */
        function prepareAndSubmit(event) {
            event.preventDefault();

            // 1. 필수 입력 체크 (제목 등)
            const title = document.getElementById('title').value;
            if(!title.trim()) {
                alert("문서 제목을 입력해 주세요.");
                document.getElementById('title').focus();
                return;
            }

            // 2. JSON 내용 구성
            const vacationData = {
                title: title, // JSON 안에도 제목을 넣어두면 관리하기 편합니다.
                applicantName: document.getElementById('applicantName').value,
                department: document.getElementById('department').value,
                vacationType: document.getElementById('vacationType').value,
                startDate: document.getElementById('startDate').value,
                endDate: document.getElementById('endDate').value,
                reason: document.getElementById('reason').value,
                contactInfo: document.getElementById('contactInfo').value
            };

            // 3. JSON 변환 후 hidden 필드에 할당
            document.getElementById('jsonContent').value = JSON.stringify(vacationData);

            // 4. 최종 제출
            document.getElementById('vacationForm').submit();
        }
    </script>
</body>
</html>