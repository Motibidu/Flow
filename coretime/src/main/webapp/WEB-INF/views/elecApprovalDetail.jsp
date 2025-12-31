<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>전자결재 상세 보기</title>
<link rel="stylesheet" href='/resources/css/vacationRequestForm.css' type="text/css">
<%-- 이전에 작성된 스타일을 여기에 포함하거나, 외부 CSS 파일에 링크할 수 있습니다 --%>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<style>
    body {
        font-family: 'Malgun Gothic', Dotum, Arial, Tahoma;
        font-size: 9pt;
        line-height: 1.5;
        color: #333;
    }
    .container {
        width: 800px;
        margin: 20px auto;
        border: 1px solid #ccc;
        padding: 30px;
        box-shadow: 0 0 10px rgba(0,0,0,0.05);
        background-color: #fff;
    }
    h1 {
        text-align: center;
        font-size: 2.5em;
        color: #333;
        margin-bottom: 30px;
        border-bottom: 2px solid #eee;
        padding-bottom: 10px;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 25px;
    }
    table th, table td {
        padding: 10px;
        border: 1px solid #ddd;
        text-align: left;
    }
    table th {
        background-color: #e0e0e0;
        font-weight: bold;
        text-align: center;
        width: 120px;
    }
    table td {
        background-color: #f9f9f9;
    }
    table tbody tr:nth-child(even) td {
        background-color: #f5f5f5;
    }
    .read-only-field {
        background-color: #f5f5f5;
        padding: 8px;
        border: 1px solid #ddd;
    }
    .approval-line {
        margin-top: 25px;
        margin-bottom: 25px;
        border: 1px solid #ddd;
    }
    .approval-line th, .approval-line td {
        padding: 0;
        text-align: center;
        border: 1px solid #ddd;
    }
    .approval-line th {
        width: 100px;
        background-color: #e0e0e0;
        vertical-align: middle;
        font-weight: bold;
        height: 80px;
    }
    .approval-sub-table {
        width: 100%;
        border-collapse: collapse;
    }
    .approval-sub-table td {
        padding: 5px;
        border: none;
    }
    .approval-date {
        font-size: 0.8em;
        color: #666;
    }
    .info-section {
        font-size: 0.9em;
        line-height: 1.6;
        color: #555;
        background-color: #f8f9fa;
        padding: 15px;
        border: 1px dashed #e0e0e0;
        border-radius: 5px;
        margin-top: 20px;
    }
    .info-section strong {
        color: #333;
    }
    .form-section-title {
        font-size: 1.2em;
        font-weight: bold;
        margin-top: 30px;
        margin-bottom: 15px;
        padding-bottom: 5px;
        border-bottom: 1px solid #ddd;
        color: #007bff;
    }

    .approval{
        display: flex;
        flex-direction: column;
        align-items: center; 
        padding: 15px;
        width: 100%;
        background-color: #f5f5f5;
    }

    .approval__comment{
        width: 60%;
        margin-bottom: 15px;
        
    }
</style>
</head>
<body>
    <div class="container">
        <h1>전자결재 상세 보기</h1>
        <div class="form-section-title">결재선</div>
        
        
        <table class="approval-line">
            <tbody>
                <tr>
                    <th>신청</th>
                    <td>
                        <table class="approval-sub-table">
                            <tbody>
                                <tr><td>${currentUser.getRankName()}</td></tr>
                                <tr><td>${currentUser.getName()}</td></tr>
                                <tr><td class="approval-date"><fmt:formatDate value="${documentDetail.getDraftDate()}" pattern="yyyy-MM-dd HH:mm:ss" /></td></tr>
                            </tbody>
                        </table>
                    </td>
                    <th>승인</th>
                    <c:forEach var="approvalHistory" items="${approvalHistories}">
                        <td>
                            <table class="approval-sub-table">
                                <tbody>
                                    <tr><td>${approvalHistory.getApproverRank()}</td></tr>
                                    <tr><td>${approvalHistory.getApproverName()}</td></tr>
                                    <tr><td><fmt:formatDate value="${approvalHistory.getActionDate()}" pattern="yyyy-MM-dd HH:mm:ss" /></td></tr>
                                </tbody>
                            </table>
                        </td>
                    </c:forEach>
                </tr>
            </tbody>
        </table>

        <div class="form-section-title">상세 신청 내용 (휴가 신청서)</div>
        <table>
            <colgroup>
                <col style="width: 120px;">
                <col style="width: auto;">
            </colgroup>
            <tbody>
                <tr>
                    <th>신청자</th>
                    <td id="jsonApplicantName" class="read-only-field"></td>
                </tr>
                <tr>
                    <th>부서</th>
                    <td id="jsonDepartment" class="read-only-field"></td>
                </tr>
                <tr>
                    <th>휴가 종류</th>
                    <td id="jsonVacationType" class="read-only-field"></td>
                </tr>
                <tr>
                    <th>시작일</th>
                    <td id="jsonStartDate" class="read-only-field"></td>
                </tr>
                <tr>
                    <th>종료일</th>
                    <td id="jsonEndDate" class="read-only-field"></td>
                </tr>
                <tr>
                    <th>사유</th>
                    <td id="jsonReason" class="read-only-field"></td>
                </tr>
                <tr>
                    <th>비상 연락처</th>
                    <td id="jsonContactInfo" class="read-only-field"></td>
                </tr>
            </tbody>
        </table>
        <c:if test="${currentUser.id eq currentApproverId and (documentDetail.status eq 'PENDING' or documentDetail.status eq 'IN_PROGRESS')}">
            <div class="approval">
                <textarea class= "approval__comment"id="approvalComment" placeholder="결재 의견을 입력하세요 (반려 시 필수)"></textarea>
                <div class="approval__buttons">
                    <button class="btn btn-outline-secondary btn-approve" onclick="submitApproval(${documentDetail.docId}, 'APPROVED')">승인</button>
                    <button class="btn btn-outline-secondary btn-reject" onclick="submitApproval(${documentDetail.docId}, 'REJECTED')">반려</button>
                </div>
            </div>
        </c:if>
        <div class="form-actions">
            <button type="button" class="cancel-button" onclick="history.back()">목록으로 돌아가기</button>
            <%-- 상신 취소 버튼  --%>
            <c:if test="${currentUser.id eq documentDetail.initiatorId and documentDetail.status eq 'PENDING'}">
                <button type="button" class="btn btn-danger" onclick="recallDocument(${documentDetail.docId})">상신 취소</button>
            </c:if>

            <%-- 재기안 버튼 : 상태가 반려(REJECTED) 또는 상신취소(RECALLED)일 때만 노출 --%>
            <c:if test="${currentUser.id eq documentDetail.initiatorId and (documentDetail.status eq 'REJECTED' or documentDetail.status eq 'RECALLED')}">
                <button type="button" class="btn btn-warning" onclick="redraftDocument(${documentDetail.docId})">재기안</button>
            </c:if>
        </div>
    </div>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 서버에서 전달받은 documentDetail 객체의 jsonContent 값을 가져옴
            const jsonContentString = '<c:out value="${documentDetail.getJsonContent()}" escapeXml="false"/>';

            if (jsonContentString) {
                try {
                    const jsonData = JSON.parse(jsonContentString);
                    console.log("Parsed JSON Content:", jsonData); // 파싱된 데이터 확인

                    // doc_type에 따라 다른 필드를 표시할 수 있도록 확장 가능
                    // 현재는 휴가 신청서 (vacationRequestForm)를 가정
                    const docType = '${documentDetail.getDocType()}'; 
                    console.log("docType: ", docType);

                    if (docType === '휴가신청서' || docType === 'VACATION_REQUEST') { // 실제 DB 저장된 값과 비교
                        document.getElementById('jsonApplicantName').innerText = jsonData.applicantName || '';
                        document.getElementById('jsonDepartment').innerText = jsonData.department || '';
                        document.getElementById('jsonVacationType').innerText = jsonData.vacationType || '';
                        document.getElementById('jsonStartDate').innerText = jsonData.startDate || '';
                        document.getElementById('jsonEndDate').innerText = jsonData.endDate || '';
                        document.getElementById('jsonReason').innerText = jsonData.reason || '';
                        document.getElementById('jsonContactInfo').innerText = jsonData.contactInfo || '';
                    } 
                    // else if (docType === '다른양식타입') {
                    //     // 다른 양식에 맞는 필드를 여기에 표시
                    // }
                    // ...
                } catch (e) {
                    console.error("JSON 파싱 오류:", e);
                    document.getElementById('jsonContentError').innerText = "JSON 내용을 파싱하는 데 오류가 발생했습니다.";
                }
            } else {
                console.log("json_content가 비어있습니다.");
            }
        });
        // 결재 승인/반려 요청을 보낼 JavaScript 함수
        function submitApproval(docId, action) {
            const comment = document.getElementById('approvalComment').value;
            console.log("action: ", action);
            if (action === 'REJECTED' && comment.trim() === '') {
                alert('반려 시에는 반드시 의견을 입력해야 합니다.');
                return;
            }
            if(action== "APPROVED"){
                confirm("승인하시겠습니까?");
            }
            else{
                confirm("반려하시겠습니까?");
            }

            fetch("/elecApproval/approval/"+docId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    // 'X-CSRF-TOKEN': document.querySelector('meta[name="_csrf_token"]').content
                },
                body: JSON.stringify({ action: action, comment: comment })
            })
            .then(response => {
                if (!response.ok) {
                    // 서버에서 에러 응답 (4xx, 5xx)이 왔을 경우
                    return response.json().then(error => { throw new Error(error.message || '승인/반려 처리 중 오류가 발생했습니다.'); });
                }
                return response.json(); // 성공 응답을 JSON으로 파싱
            })
            .then(data => {
                alert(data.message); // 서버로부터 받은 메시지 (예: "결재가 승인되었습니다.")
                window.location.href = '/elecApproval'; // 결재 목록 페이지로 리다이렉트 (메인 대시보드)
            })
            .catch(error => {
                console.error('Error:', error);
                alert('요청 처리 중 오류가 발생했습니다: ' + error.message);
            });
        }

        // 상신 취소(기안 회수) 요청 함수
        function recallDocument(docId) {
            if (!confirm("이 문서를 상신 취소하시겠습니까?")) {
                return;
            }

            axios.post("/elecApproval/recall/" + docId)
                .then(response => {
                    alert(response.data.message || '상신 취소가 완료되었습니다.');
                    window.location.href = '/elecApproval';
                })
                .catch(error => {
                    console.error('Error:', error);
                    const msg = error.response ? error.response.data.message : error.message;
                    alert('요청 처리 중 오류가 발생했습니다: ' + msg);
                });
        }

        function redraftDocument(docId) {
            if (confirm("이 문서의 내용을 수정하여 다시 기안하시겠습니까?")) {
                location.href = "/elecApproval/edit/" + docId;
            }
        }
    </script>
</body>
</html>