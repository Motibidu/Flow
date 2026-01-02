<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>전자결재 상세 보기</title>
    <%-- 공통 헤더 (SockJS, STOMP 포함됨) --%>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

    <style>
        /* ----- 대시보드(elecApproval.jsp)와 통일된 기본 스타일 ----- */
        body {
            font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
            background-color: #f4f7f6;
            color: #333;
            margin: 0;
            font-size: 14px;
        }

        .content {
            display: flex;
            gap: 20px;
        }

        .main {
            width: 100%;
            padding: 20px;
        }

        .main h1 {
            font-size: 24px;
            font-weight: 600;
            color: #1a2a44;
            margin-bottom: 25px;
            border-bottom: 2px solid #e0e0e0;
            padding-bottom: 10px;
        }

        /* ----- 카드(위젯) 디자인 ----- */
        .widget {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .widget h2 {
            font-size: 18px;
            color: #1a2a44;
            margin-top: 0;
            margin-bottom: 20px;
            border-left: 4px solid #007bff;
            padding-left: 12px;
        }

        /* ----- 상세 내용 테이블 ----- */
        .detail-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 10px;
        }

        .detail-table th {
            width: 160px;
            background-color: #f8f9fa;
            color: #495057;
            font-weight: 600;
            padding: 12px 15px;
            border: 1px solid #dee2e6;
            text-align: center;
        }

        .detail-table td {
            padding: 12px 15px;
            border: 1px solid #dee2e6;
            background-color: #fff;
        }

        /* ----- 결재선 박스 디자인 ----- */
        .approval-line-container {
            display: flex;
            gap: 12px;
            margin-bottom: 5px;
            flex-wrap: wrap;
        }

        .approval-box {
            border: 1px solid #dee2e6;
            text-align: center;
            width: 130px;
            border-radius: 6px;
            overflow: hidden;
            background-color: #fff;
        }

        .approval-box .role {
            background-color: #f8f9fa;
            padding: 6px;
            border-bottom: 1px solid #dee2e6;
            font-weight: bold;
            font-size: 12px;
            color: #555;
        }

        .approval-box .name {
            padding: 12px 5px;
            font-weight: 600;
            font-size: 15px;
            color: #333;
        }

        .approval-box .date {
            padding: 6px;
            font-size: 11px;
            color: #999;
            border-top: 1px dashed #eee;
            min-height: 15px;
        }

        /* ----- 결재 의견 입력창 ----- */
        .approval-action-area {
            background-color: #f8f9fb;
            border: 1px solid #d1d9e6;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }

        .approval-action-area textarea {
            width: 100%;
            height: 100px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            padding: 12px;
            margin-bottom: 15px;
            resize: none;
            font-family: inherit;
        }

        /* ----- 상태 배지 (메인과 동일) ----- */
        .status-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            color: #fff;
        }
        .status-APPROVED { background-color: #28a745; }
        .status-REJECTED { background-color: #dc3545; }
        .status-RECALLED { background-color: #6c757d; }
        .status-PENDING { background-color: #ffc107; color: #212529; }
        .status-IN_PROGRESS { background-color: #17a2b8; }

        /* ----- 버튼 스타일 통합 ----- */
        .btn {
            padding: 10px 22px;
            border-radius: 5px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            font-size: 14px;
            display: inline-block;
            text-decoration: none;
            text-align: center;
        }
        .btn-primary { background-color: #007bff; color: white; }
        .btn-secondary { background-color: #6c757d; color: white; }
        .btn-danger { background-color: #dc3545; color: white; }
        .btn-warning { background-color: #ffc107; color: #212529; }
        .btn-outline-secondary { border: 1px solid #6c757d; color: #6c757d; background: #fff; }

        .action-group {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 40px;
            margin-bottom: 50px;
        }
    </style>
</head>
<body>

    <div class="header">
        <%@ include file="header.jsp"%>
    </div>

    <div class="content">
        <div id="nav">
            <%@ include file="leftNav.jsp"%>
        </div>

        <div class="main">
            <h1>전자결재 상세 보기</h1>

            <div class="widget">
                <h2>결재선</h2>
                <div class="approval-line-container">
                    <div class="approval-box">
                        <div class="role">신청</div>
                        <div class="name">${documentDetail.initiatorName}</div>
                        <div class="date">
                            <fmt:formatDate value="${documentDetail.draftDate}" pattern="yyyy-MM-dd HH:mm"/>
                        </div>
                    </div>

                    <c:forEach var="history" items="${approvalHistories}">
                        <div class="approval-box">
                            <div class="role">${history.approverRank}</div>
                            <div class="name">${history.approverName}</div>
                            <div class="date">
                                <c:choose>
                                    <c:when test="${not empty history.actionDate}">
                                        <fmt:formatDate value="${history.actionDate}" pattern="yyyy-MM-dd HH:mm"/>
                                    </c:when>
                                    <c:otherwise><span style="color:#ccc">대기</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div class="widget">
                <h2>상세 신청 내용 [${documentDetail.docType}]</h2>
                <table class="detail-table">
                    <tbody>
                        <tr>
                            <th>문서 상태</th>
                            <td><span class="status-badge status-${documentDetail.status}">${documentDetail.status}</span></td>
                        </tr>
                        <tr>
                            <th>신청자 / 부서</th>
                            <td><strong><span id="jsonApplicantName"></span></strong> (<span id="jsonDepartment"></span>)</td>
                        </tr>
                        <tr>
                            <th>휴가 종류</th>
                            <td id="jsonVacationType"></td>
                        </tr>
                        <tr>
                            <th>신청 기간</th>
                            <td><span id="jsonStartDate"></span> ~ <span id="jsonEndDate"></span></td>
                        </tr>
                        <tr>
                            <th>신청 사유</th>
                            <td id="jsonReason"></td>
                        </tr>
                        <tr>
                            <th>비상 연락처</th>
                            <td id="jsonContactInfo"></td>
                        </tr>
                    </tbody>
                </table>

                <c:if test="${currentUser.id eq currentApproverId and (documentDetail.status eq 'PENDING' or documentDetail.status eq 'IN_PROGRESS')}">
                    <div class="approval-action-area">
                        <textarea id="approvalComment" placeholder="결재 의견을 입력해 주세요. (반려 시 사유 필수 입력)"></textarea>
                        <div style="text-align: right; gap: 10px; display: flex; justify-content: flex-end;">
                            <button class="btn btn-primary" onclick="submitApproval(${documentDetail.docId}, 'APPROVED')">승인</button>
                            <button class="btn btn-danger" onclick="submitApproval(${documentDetail.docId}, 'REJECTED')">반려</button>
                        </div>
                    </div>
                </c:if>
            </div>

            <div class="action-group">
                <button class="btn btn-secondary" onclick="location.href='/elecApproval'">목록으로</button>

                <%-- 기안자 본인 + 대기 중일 때만 상신취소 가능 --%>
                <c:if test="${currentUser.id eq documentDetail.initiatorId and documentDetail.status eq 'PENDING'}">
                    <button class="btn btn-outline-secondary" onclick="recallDocument(${documentDetail.docId})">상신 취소</button>
                </c:if>

                <%-- 반려 또는 취소된 경우 재기안 가능 --%>
                <c:if test="${currentUser.id eq documentDetail.initiatorId and (documentDetail.status eq 'REJECTED' or documentDetail.status eq 'RECALLED')}">
                    <button class="btn btn-warning" onclick="redraftDocument(${documentDetail.docId})">수정 후 재기안</button>
                    <button type="button" class="btn btn-danger" onclick="deleteDocument(${documentDetail.docId})">문서 삭제</button>
                </c:if>
                
            </div>
        </div>
    </div>

    <%-- 부트스트랩 CSS (헤더와 일관성) --%>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // JSON 데이터 파싱 및 매핑
            const jsonContentString = '${documentDetail.jsonContent}';
            console.log(jsonContentString);

            if (jsonContentString) {
                try {
                    const jsonData = JSON.parse(jsonContentString);
                    const docType = '${documentDetail.docType}';

                    // 휴가 신청서 양식 매핑
                    if (docType.includes('휴가') || docType === 'VACATION_REQUEST') {
                        document.getElementById('jsonApplicantName').innerText = jsonData.applicantName || '-';
                        document.getElementById('jsonDepartment').innerText = jsonData.department || '-';
                        document.getElementById('jsonVacationType').innerText = jsonData.vacationType || '-';
                        document.getElementById('jsonStartDate').innerText = jsonData.startDate || '-';
                        document.getElementById('jsonEndDate').innerText = jsonData.endDate || '-';
                        document.getElementById('jsonReason').innerText = jsonData.reason || '-';
                        document.getElementById('jsonContactInfo').innerText = jsonData.contactInfo || '-';
                    }
                } catch (e) {
                    console.error("JSON 파싱 오류:", e);
                }
            }
        });

        // 승인 및 반려 처리
        function submitApproval(docId, action) {
            const comment = document.getElementById('approvalComment').value;
            const actionText = (action === 'APPROVED') ? '승인' : '반려';

            if (action === 'REJECTED' && comment.trim() === '') {
                alert('반려 시에는 반드시 의견을 입력해야 합니다.');
                return;
            }

            if (!confirm(actionText + " 하시겠습니까?")) return;

            fetch("/elecApproval/approval/" + docId, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: action, comment: comment })
            })
            .then(response => {
                if (!response.ok) return response.json().then(error => { throw new Error(error.message); });
                return response.json();
            })
            .then(data => {
                alert(data.message);
                window.location.href = '/elecApproval';
            })
            .catch(error => alert('처리 중 오류 발생: ' + error.message));
        }

        // 상신 취소
        function recallDocument(docId) {
            if (!confirm("이 문서를 상신 취소하시겠습니까?")) return;

            axios.post("/elecApproval/recall/" + docId)
                .then(response => {
                    alert(response.data.message || '상신 취소가 완료되었습니다.');
                    window.location.href = '/elecApproval';
                })
                .catch(error => {
                    const msg = error.response ? error.response.data.message : error.message;
                    alert('오류 발생: ' + msg);
                });
        }

        // 재기안 페이지 이동
        function redraftDocument(docId) {
            if (confirm("내용을 수정하여 다시 기안하시겠습니까?")) {
                location.href = "/elecApproval/edit/" + docId;
            }
        }

        function deleteDocument(docId) {
            if (!confirm("문서를 영구적으로 삭제하시겠습니까? 삭제 후에는 복구할 수 없습니다.")) {
                return;
            }

            axios.delete("/elecApproval/delete/" + docId)
                .then(response => {
                    alert(response.data.message || '문서가 삭제되었습니다.');
                    window.location.href = '/elecApproval'; // 목록으로 이동
                })
                .catch(error => {
                    const msg = error.response ? error.response.data.message : error.message;
                    alert('삭제 중 오류 발생: ' + msg);
                });
        }
    </script>
</body>
</html>