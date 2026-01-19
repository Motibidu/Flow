<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="일반 품의서 상세 보기">
    <jsp:body>

        <%-- 1. Load Common CSS --%>
        <link rel="stylesheet" href="/resources/css/approval.css">

        <%-- 2. Page-Specific Styles --%>
        <style>
            /* [General Proposal Specific - Content View] */
            .content-view { 
                width: 100%; 
                min-height: 400px; 
                padding: 20px; 
                border: 1px solid #ddd; 
                border-radius: 4px; 
                box-sizing: border-box; 
                background-color: #fff; 
                white-space: pre-wrap; 
                line-height: 1.6; 
                font-size: 14px; 
            }

            /* [Approval Action Area] */
            .approval-action-area { background-color: #f8f9fb; border: 1px solid #d1d9e6; padding: 25px; border-radius: 8px; margin-top: 40px; }
            .approval-action-area h4 { margin-top: 0; font-size: 16px; margin-bottom: 10px; color: #333; }
            .approval-action-area textarea { width: 100%; height: 100px; padding: 12px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; resize: vertical; }

            /* [Status Badges & Stamps] */
            .stamp-status { font-size: 12px; font-weight: bold; margin-bottom: 2px; }
            .status-badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; color: #fff; }
            .status-APPROVED { background-color: #28a745; }
            .status-REJECTED { background-color: #dc3545; }
            .status-PENDING { background-color: #ffc107; color: #212529; }
            .status-RECALLED { background-color: #6c757d; }

            /* [Button Overrides if needed] */
            .btn-primary { background: #007bff; color: white; border: none; }
            .btn-danger { background: #dc3545; color: white; border: none; }
            .btn-warning { background: #ffc107; color: #212529; border: none; }
            .btn-outline { background: #fff; color: #333; border: 1px solid #ccc; }
            .btn-outline:hover { background: #f8f9fa; }
        </style>

        <%-- 3. Main Content --%>
        <div class="approval-container">
            <div class="doc-title">일 반 품 의 서</div>

            <div class="approval-table-wrapper">
                <div class="approval-box">
                    <div class="role">기안</div>
                    <div class="name">${document.initiatorName}</div>
                    <div class="date"><fmt:formatDate value="${document.draftDate}" pattern="yyyy-MM-dd"/></div>
                </div>
                <c:forEach var="history" items="${document.approvalHistories}">
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
                <tr>
                    <th>첨부파일</th>
                    <td colspan="3">
                        <c:choose>
                            <%-- 1. 첨부파일이 없는 경우 --%>
                            <c:when test="${empty document.attachments}">
                                <span style="color: #999; font-size: 13px;">첨부된 파일이 없습니다.</span>
                            </c:when>
                            
                            <%-- 2. 첨부파일이 있는 경우 (리스트 반복) --%>
                            <c:otherwise>
                                <div style="display: flex; flex-direction: column; gap: 5px;">
                                    <c:forEach items="${document.attachments}" var="file">
                                        <div style="display: flex; align-items: center;">
                                            <span style="margin-right: 5px;">📎</span>
                                            
                                            <a href="/elecApproval/download/${file.docId}" 
                                            style="color: #007bff; text-decoration: none; font-size: 14px;"
                                            onmouseover="this.style.textDecoration='underline'" 
                                            onmouseout="this.style.textDecoration='none'">
                                                ${file.originName}
                                            </a>
                                            
                                            <span style="color: #888; font-size: 12px; margin-left: 8px;">
                                                (<fmt:formatNumber value="${file.fileSize / 1024}" pattern="#,###"/> KB)
                                            </span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </table>

            <div style="margin-top: 20px;">
                <span style="font-weight: bold; font-size: 15px; border-left: 4px solid #007bff; padding-left: 8px;">품의 내용</span>
                <div id="proposalContent" class="content-view" style="margin-top: 10px;"></div>
            </div>

            <c:if test="${document.currentApproverId eq currentUser.id and (document.status eq 'PENDING' or document.status eq 'IN_PROGRESS')}">
                <div class="approval-action-area">
                    <h4>결재 처리</h4>
                    <textarea id="approvalComment" placeholder="결재 의견을 입력해 주세요. (반려 시 사유 필수 입력)"></textarea>
                    <div style="text-align: right; gap: 10px; display: flex; justify-content: flex-end; margin-top: 10px;">
                        <button type="button" class="btn btn-primary" onclick="submitApproval('APPROVED')">승인</button>
                        <button type="button" class="btn btn-danger" onclick="submitApproval('REJECTED')">반려</button>
                    </div>
                </div>
            </c:if>

            <%-- 대리 결재 처리 영역 --%>
            <%-- TODO: 대리 결재 가능 조건에 대한 구체적인 비즈니스 로직 적용 필요 --%>
            <c:if test="${currentUser.id ne document.currentApproverId and currentUser.id ne document.initiatorId and (document.status eq 'PENDING' or document.status eq 'IN_PROGRESS')}">
                <div class="approval-action-area">
                    <h4>대리 결재 처리</h4>
                    <textarea id="substituteApprovalComment" placeholder="대리 결재 의견을 입력해 주세요. (반려 시 사유 필수 입력)"></textarea>
                    <div style="text-align: right; gap: 10px; display: flex; justify-content: flex-end; margin-top: 10px;">
                        <button type="button" class="btn btn-primary" onclick="submitSubstituteApproval('APPROVED')">대리 승인</button>
                        <button type="button" class="btn btn-danger" onclick="submitSubstituteApproval('REJECTED')">대리 반려</button>
                    </div>
                </div>
            </c:if>

            <div class="btn-group">
                <button type="button" class="btn btn-outline" onclick="goBackToList()">목록으로</button>

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

        <%-- 4. Scripts --%>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const jsonStr = document.getElementById('jsonRawData').value;
                if (jsonStr) {
                    try {
                        const data = JSON.parse(jsonStr);
                        // Bind proposal content
                        document.getElementById('proposalContent').innerText = data.content || "내용 없음";
                    } catch (e) { console.error(e); }
                }
            });

            // Common functions
            function submitApproval(action) {
                const comment = document.getElementById('approvalComment').value;
                if (action === 'REJECTED' && !comment.trim()) { alert('반려 사유 입력 필수'); return; }
                if(!confirm(action === 'APPROVED' ? "승인하시겠습니까?" : "반려하시겠습니까?")) return;

                const url = action === 'APPROVED' ? "/elecApproval/approve/${document.docId}" : "/elecApproval/reject/${document.docId}";
                axios.post(url, { comment: comment })
                    .then(res => { alert(res.data.message); location.href = "/elecApproval/detail/"+ ${document.docId}; })
                    .catch(err => {
                        const errorMessage = err.response && err.response.data && err.response.data.message ? err.response.data.message : "오류가 발생했습니다.";
                        alert(errorMessage);
                    });
            }
            
            // 대리 결재 승인/반려
            function submitSubstituteApproval(action) {
                const comment = document.getElementById('substituteApprovalComment').value;
                if (action === 'REJECTED' && !comment.trim()) { alert('반려 사유 입력 필수'); return; }
                if(!confirm(action === 'APPROVED' ? "대리 승인하시겠습니까?" : "대리 반려하시겠습니까?")) return;
                const url = action === 'APPROVED' ? "/elecApproval/substitute-approve/${document.docId}" : "/elecApproval/substitute-reject/${document.docId}";
                axios.post(url, { comment: comment })
                    .then(res => { alert(res.data.message); location.href = "/elecApproval/detail/"+ ${document.docId}; })
                    .catch(err => {
                        const errorMessage = err.response && err.response.data && err.response.data.message ? err.response.data.message : "오류가 발생했습니다.";
                        alert(errorMessage);
                    });
            }

            function recallDocument(docId) { 
                if(confirm("상신 취소하시겠습니까?")) {
                    axios.post("/elecApproval/recall/" + docId)
                        .then(res => { alert(res.data.message); location.href = '/elecApproval'; })
                        .catch(err => {
                            const errorMessage = err.response && err.response.data && err.response.data.message ? err.response.data.message : "오류가 발생했습니다.";
                            alert(errorMessage);
                        });
                }
            }
            
            function redraftDocument(docId) { location.href = "/elecApproval/documents/" + docId; }
            
            function deleteDocument(docId) { 
                if(confirm("영구 삭제하시겠습니까?")) {
                    axios.delete("/elecApproval/delete/" + docId)
                        .then(res => { alert(res.data.message); location.href = '/elecApproval'; })
                        .catch(err => {
                            const errorMessage = err.response && err.response.data && err.response.data.message ? err.response.data.message : "오류가 발생했습니다.";
                            alert(errorMessage);
                        });
                }
            }

            function goBackToList() {
                const status = '${document.status}';
                const isApprover = '${document.currentApproverId}' === '${currentUser.id}';

                if (status === 'TEMP') {
                    location.href = '/elecApproval/temp';
                } else if (status === 'APPROVED') {
                    location.href = '/elecApproval/approved';
                } else if (status === 'REJECTED' || status === 'RECALLED') {
                    location.href = '/elecApproval/rejected-or-recalled';
                } else if (status === 'PENDING' || status === 'IN_PROGRESS') {
                    if (isApprover) location.href = '/elecApproval/my-turn';
                    else location.href = '/elecApproval/pending-or-progress';
                } else {
                    location.href = '/elecApproval';
                }
            }
        </script>
    </jsp:body>
</t:layout>