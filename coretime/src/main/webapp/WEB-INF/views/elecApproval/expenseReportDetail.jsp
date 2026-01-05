<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지출 결의서 상세 보기</title>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <style>
        /* [공통 레이아웃] */
        body { font-family: 'Malgun Gothic', '맑은 고딕', sans-serif; background-color: #f4f7f6; color: #333; margin: 0; padding: 20px; }
        .approval-container { width: 850px; margin: 30px auto; background: #fff; padding: 50px; border: 1px solid #ddd; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .doc-title { text-align: center; font-size: 32px; font-weight: bold; text-decoration: underline; margin-bottom: 40px; color: #1a2a44; }

        /* [상단 결재선] */
        .approval-table-wrapper { display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 30px; }
        .approval-box { border: 1px solid #000; text-align: center; width: 110px; background-color: #fff; }
        .approval-box .role { background-color: #f2f2f2; padding: 5px; border-bottom: 1px solid #000; font-weight: bold; font-size: 12px; }
        .approval-box .name { padding: 15px 5px; font-weight: 600; font-size: 14px; min-height: 40px; display: flex; align-items: center; justify-content: center; flex-direction: column; }
        .approval-box .date { font-size: 11px; color: #666; border-top: 1px dashed #ddd; padding: 5px; background: #fafafa; }
        .stamp-status { font-size: 12px; font-weight: bold; margin-bottom: 2px; }

        /* [정보 테이블] */
        .info-table { width: 100%; border-collapse: collapse; margin-bottom: 25px; }
        .info-table th { width: 140px; border: 1px solid #ddd; padding: 12px; background: #f9f9f9; text-align: left; font-weight: 600; color: #495057; }
        .info-table td { border: 1px solid #ddd; padding: 12px; background-color: #fff; }

        /* [지출 내역 테이블 (헤더 색상 다름)] */
        .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; border-top: 2px solid #333; }
        .items-table th { border: 1px solid #ddd; padding: 10px; background: #f2f2f2; text-align: center; font-size: 14px; font-weight: bold; }
        .items-table td { border: 1px solid #ddd; padding: 10px; text-align: center; font-size: 14px; }
        .text-right { text-align: right !important; }
        .total-area { margin-top: 20px; padding: 15px; background: #f8f9fa; border: 1px solid #ddd; text-align: right; font-size: 18px; font-weight: bold; color: #1a2a44; }

        /* [비고란] */
        .remark-box { width: 100%; min-height: 80px; border: 1px solid #ddd; padding: 15px; margin-top: 10px; background: #fff; white-space: pre-wrap; box-sizing: border-box; }

        /* [결재 의견 입력창 (회색 박스)] */
        .approval-action-area { background-color: #f8f9fb; border: 1px solid #d1d9e6; padding: 25px; border-radius: 8px; margin-top: 40px; }
        .approval-action-area h4 { margin-top: 0; font-size: 16px; margin-bottom: 10px; color: #333; }
        .approval-action-area textarea { width: 100%; height: 100px; padding: 12px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; resize: vertical; }

        /* [하단 버튼 그룹] */
        .btn-group { text-align: center; margin-top: 40px; display: flex; justify-content: center; gap: 12px; }
        .btn { padding: 12px 28px; border-radius: 4px; cursor: pointer; font-weight: bold; border: 1px solid #ccc; text-decoration: none; font-size: 15px; }
        .btn-primary { background: #007bff; color: white; border: none; }
        .btn-danger { background: #dc3545; color: white; border: none; }
        .btn-warning { background: #ffc107; color: #212529; border: none; }
        .btn-outline { background: #fff; color: #333; border: 1px solid #ccc; }
        .btn-outline:hover { background: #f8f9fa; }

        /* [상태 배지] */
        .status-badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; color: #fff; }
        .status-APPROVED { background-color: #28a745; }
        .status-REJECTED { background-color: #dc3545; }
        .status-PENDING { background-color: #ffc107; color: #212529; }
        .status-RECALLED { background-color: #6c757d; }
    </style>
</head>
<body>
    <div class="approval-container">
        <div class="doc-title">지 출 결 의 서</div>

        <div class="approval-table-wrapper">
            <div class="approval-box">
                <div class="role">기안</div>
                <div class="name">${document.initiatorName}</div>
                <div class="date"><fmt:formatDate value="${document.draftDate}" pattern="yyyy-MM-dd"/></div>
            </div>
            <c:forEach var="history" items="${approvalHistories}">
                <div class="approval-box">
                    <div class="role">${history.approverRank.displayName}</div>
                    <div class="name">
                        <c:if test="${not empty history.actionDate}">
                            <div class="stamp-status" style="color: ${history.approvalStatus eq 'REJECTED' ? '#dc3545' : '#28a745'}">
                                ${history.approvalStatus eq 'REJECTED' ? '반려' : '승인'}
                            </div>
                        </c:if>
                        ${history.approverName}
                    </div>
                    <div class="date">
                        <c:choose>
                            <c:when test="${not empty history.actionDate}"><fmt:formatDate value="${history.actionDate}" pattern="MM-dd"/></c:when>
                            <c:otherwise><span style="color:#ccc">대기</span></c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </div>

        <table class="info-table">
            <tr>
                <th>문서상태</th>
                <td><span class="status-badge status-${document.status}">${document.status}</span></td>
                <th>문서번호</th>
                <td>${document.docId}</td>
            </tr>
            <tr>
                <th>기안부서</th>
                <td>${document.initiatorDepartment.displayName}</td>
                <th>기안자</th>
                <td>${document.initiatorName}</td>
            </tr>
            <tr>
                <th>기안일자</th>
                <td colspan="3"><fmt:formatDate value="${document.draftDate}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
            </tr>
            <tr>
                <th>문서제목</th>
                <td colspan="3" style="font-weight: bold; font-size: 16px;">${document.title}</td>
            </tr>
        </table>

        <div style="margin-top: 30px;">
            <span style="font-weight: bold; font-size: 15px; border-left: 4px solid #007bff; padding-left: 8px;">지출 세부 내역</span>
            <table class="items-table">
                <thead>
                    <tr>
                        <th style="width: 150px;">일자</th>
                        <th style="width: 150px;">항목</th>
                        <th>상세내용</th>
                        <th style="width: 150px;">금액</th>
                    </tr>
                </thead>
                <tbody id="itemsBody"></tbody>
            </table>
        </div>

        <div class="total-area">
            총 합계 금액: <span id="totalDisplay">0</span>원
        </div>

        <div style="margin-top: 20px;">
            <span style="font-weight: bold; font-size: 15px; border-left: 4px solid #007bff; padding-left: 8px;">비고 및 특이사항</span>
            <div class="remark-box" id="remarkContent"></div>
        </div>

        <c:if test="${currentUser.id eq currentApproverId and (document.status eq 'PENDING' or document.status eq 'IN_PROGRESS')}">
            <div class="approval-action-area">
                <h4>결재 처리</h4>
                <textarea id="approvalComment" placeholder="결재 의견을 입력해 주세요. (반려 시 사유 필수 입력)"></textarea>
                <div style="text-align: right; gap: 10px; display: flex; justify-content: flex-end; margin-top: 10px;">
                    <button type="button" class="btn btn-primary" onclick="submitApproval('APPROVED')">승인</button>
                    <button type="button" class="btn btn-danger" onclick="submitApproval('REJECTED')">반려</button>
                </div>
            </div>
        </c:if>

        <div class="btn-group">
            <button type="button" class="btn btn-outline" onclick="location.href='/elecApproval'">목록으로</button>

            <c:if test="${currentUser.id eq document.initiatorId and document.status eq 'PENDING'}">
                <button class="btn btn-danger" onclick="recallDocument(${document.docId})">상신 취소</button>
            </c:if>

            <c:if test="${currentUser.id eq document.initiatorId and (document.status eq 'REJECTED' or document.status eq 'RECALLED')}">
                <button class="btn btn-warning" onclick="redraftDocument(${document.docId})">수정 후 재기안</button>
                <button class="btn btn-danger" onclick="deleteDocument(${document.docId})">문서 삭제</button>
            </c:if>
        </div>
    </div>

    <input type="hidden" id="jsonRawData" value='<c:out value="${document.jsonContent}" escapeXml="false"/>'>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const jsonStr = document.getElementById('jsonRawData').value;
            try {
                const data = JSON.parse(jsonStr);
                const itemsBody = document.getElementById('itemsBody');
                
                if(data.items && data.items.length > 0) {
                    let html = "";
                    data.items.forEach(item => {
                        html += `<tr>
                                    <td>\${item.date}</td>
                                    <td>\${item.category}</td>
                                    <td style="text-align: left;">\${item.detail}</td>
                                    <td class="text-right">\${Number(item.amount).toLocaleString()}원</td>
                                </tr>`;
                    });
                    itemsBody.innerHTML = html;
                }
                document.getElementById('totalDisplay').innerText = Number(data.totalAmount || 0).toLocaleString();
                document.getElementById('remarkContent').innerText = data.remark || "내용 없음";
            } catch (e) { console.error(e); }
        });

        function submitApproval(action) {
            const comment = document.getElementById('approvalComment').value;
            if (action === 'REJECTED' && !comment.trim()) { alert('반려 사유 입력 필수'); return; }
            if(!confirm(action === 'APPROVED' ? "승인하시겠습니까?" : "반려하시겠습니까?")) return;

            axios.post("/elecApproval/approval/${document.docId}", { action: action, comment: comment })
                .then(res => { alert(res.data.message); location.href = "/elecApproval"; })
                .catch(err => alert("오류 발생"));
        }
        
        function recallDocument(docId) {
            if(confirm("상신 취소하시겠습니까?")) {
                axios.post("/elecApproval/recall/" + docId).then(res => { alert(res.data.message); location.href = '/elecApproval'; });
            }
        }
        
        function redraftDocument(docId) { location.href = "/elecApproval/edit/" + docId; }
        
        function deleteDocument(docId) {
            if(confirm("영구 삭제하시겠습니까?")) {
                axios.delete("/elecApproval/delete/" + docId).then(res => { alert(res.data.message); location.href = '/elecApproval'; });
            }
        }
    </script>
</body>
</html>