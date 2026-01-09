<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>전자결재 대시보드</title>

<style>
    /* ----- 기본 스타일 ----- */
    body { font-family: 'Malgun Gothic', '맑은 고딕', sans-serif; background-color: #f4f7f6; color: #333; margin: 0; font-size: 14px; }
    .content { display: flex; gap: 20px; }
    .main { width: 100%; padding: 20px; }
    .main h1 { font-size: 24px; font-weight: 600; color: #1a2a44; margin-bottom: 25px; border-bottom: 2px solid #e0e0e0; padding-bottom: 10px; }

    /* ----- 상단 요약 카드 (Summary Cards) ----- */
    .summary-container { display: flex; gap: 20px; margin-bottom: 25px; }
    .summary-card { flex: 1; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center; cursor: pointer; transition: transform 0.2s; border-left: 5px solid #ccc; }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
    .summary-title { font-size: 14px; color: #666; font-weight: bold; }
    .summary-count { font-size: 28px; font-weight: bold; color: #333; }
    
    .card-red { border-left-color: #dc3545; }
    .card-yellow { border-left-color: #ffc107; }
    .card-green { border-left-color: #28a745; }
    .card-blue { border-left-color: #17a2b8; }

    /* ----- 위젯 (섹션) 스타일 ----- */
    .widget { background-color: #ffffff; border-radius: 8px; padding: 20px; margin-bottom: 25px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    .widget-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
    .widget h2 { font-size: 16px; color: #1a2a44; margin: 0; font-weight: bold; display: flex; align-items: center; gap: 8px; }
    .btn-more { font-size: 12px; color: #666; text-decoration: none; padding: 4px 8px; border-radius: 4px; background: #f8f9fa; border: 1px solid #ddd; }
    .btn-more:hover { background: #e9ecef; }

    /* ----- 버튼 스타일 ----- */
    .action-buttons { margin-bottom: 20px; text-align: right; }
    .btn { padding: 8px 15px; border: none; border-radius: 5px; cursor: pointer; font-weight: 500; transition: 0.2s; }
    .btn-primary { background-color: #007bff; color: white; }
    .btn-primary:hover { background-color: #0056b3; }
    .btn-secondary { background-color: #6c757d; color: white; font-size: 11px; padding: 4px 8px; }
    .btn-secondary:hover { background-color: #5a6268; }

    /* ----- 테이블 스타일 ----- */
    .data-table { width: 100%; border-collapse: collapse; text-align: center; font-size: 13px; }
    .data-table th { background: #f8f9fa; color: #555; font-weight: 600; padding: 10px; border-bottom: 2px solid #dee2e6; }
    .data-table td { padding: 10px; border-bottom: 1px solid #eee; color: #444; }
    .data-table tr:hover { background-color: #f8f9fa; }
    .data-table a { color: #333; text-decoration: none; }
    .data-table a:hover { text-decoration: underline; color: #0056b3; }

    /* 상태 배지 */
    .status-badge { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; color: #fff; }
    .status-APPROVED { background-color: #28a745; }
    .status-REJECTED { background-color: #dc3545; }
    .status-RECALLED { background-color: #6c757d; }
    .status-PENDING { background-color: #ffc107; color: #212529; }
    .status-IN_PROGRESS { background-color: #17a2b8; }
    .no-data { text-align: center; padding: 30px; color: #999; font-size: 13px; }
</style>
</head>
<body>
    <div class="header">
        <%@ include file="../common/header.jsp"%>
    </div>
    <div class="content">
        <div id="nav">
            <%@ include file="../common/leftNav.jsp"%>
        </div>
        <div class="main">
            <h1>전자결재 대시보드</h1>

            <div class="summary-container">
                <div class="summary-card card-red" onclick="location.href='/elecApproval/my-turn'">
                    <div>
                        <div class="summary-title">결재 대기</div>
                        <div class="summary-count">${empty pendingApprovals ? 0 : pendingApprovals.size()}</div>
                    </div>
                    <div style="font-size: 24px;">🔴</div>
                </div>
                <div class="summary-card card-blue" onclick="location.href='/elecApproval/pending-or-progress'">
                    <div>
                        <div class="summary-title">진행 중</div>
                        <div class="summary-count">${empty myInProgressDocs ? 0 : myInProgressDocs.size()}</div>
                    </div>
                    <div style="font-size: 24px;">🔵</div>
                </div>
                <div class="summary-card card-yellow" onclick="location.href='/elecApproval/rejected-or-recalled'">
                    <div>
                        <div class="summary-title">반려 / 취소</div>
                        <div class="summary-count">${empty myRejectedOrRecalledDocs ? 0 : myRejectedOrRecalledDocs.size()}</div>
                    </div>
                    <div style="font-size: 24px;">🟡</div>
                </div>
                <div class="summary-card card-green" onclick="location.href='/elecApproval/approved'">
                    <div>
                        <div class="summary-title">결재 완료</div>
                        <div class="summary-count">${empty myApprovedDocs ? 0 : myApprovedDocs.size()}</div>
                    </div>
                    <div style="font-size: 24px;">🟢</div>
                </div>
            </div>

            <div class="action-buttons">
                <button class="btn btn-primary" onclick="openFormSelectionModal()">+ 새 결재 문서 작성</button>
            </div>

            <div class="widget">
                <div class="widget-header">
                    <h2>📥 나의 결재 대기 문서 <span style="font-size:12px; color:#dc3545; margin-left:5px;">(${empty pendingApprovals ? 0 : pendingApprovals.size()}건)</span></h2>
                    <a href="/elecApproval/my-turn" class="btn-more">더보기 +</a>
                </div>
                <c:choose>
                    <c:when test="${not empty pendingApprovals}">
                        <table class="data-table">
                            <colgroup>
                                <col width="8%"> <col width="*"> <col width="12%"> <col width="10%"> <col width="15%"> <col width="10%"> <col width="10%">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>NO</th> <th>제목</th> <th>양식</th> <th>기안자</th> <th>기안일</th> <th>상태</th> <th>관리</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${pendingApprovals}" end="4"> <%-- 최대 5개만 출력 --%>
                                    <tr>
                                        <td>${doc.docId}</td>
                                        <td style="text-align: left; padding-left: 15px;">
                                            <a href="/elecApproval/detail/${doc.docId}"><strong>${doc.title}</strong></a>
                                        </td>
                                        <td>${doc.docType.displayName}</td>
                                        <td>${doc.initiatorName}</td>
                                        <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd"/></td>
                                        <td><span class="status-badge status-${doc.status}">${doc.status}</span></td>
                                        <td><button class="btn btn-secondary" onclick="quickApprove(${doc.docId})">승인</button></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise><p class="no-data">처리할 결재 문서가 없습니다.</p></c:otherwise>
                </c:choose>
            </div>

            <div class="widget">
                <div class="widget-header">
                    <h2>📤 진행 중인 문서</h2>
                    <a href="/elecApproval/pending-or-progress" class="btn-more">더보기 +</a>
                </div>
                <c:choose>
                    <c:when test="${not empty myInProgressDocs}">
                        <table class="data-table">
                            <colgroup>
                                <col width="8%"> <col width="*"> <col width="15%"> <col width="15%"> <col width="10%">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>NO</th> <th>제목</th> <th>기안일</th> <th>양식</th> <th>상태</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${myInProgressDocs}" end="4">
                                    <tr>
                                        <td>${doc.docId}</td>
                                        <td style="text-align: left; padding-left: 15px;">
                                            <a href="/elecApproval/detail/${doc.docId}">${doc.title}</a>
                                        </td>
                                        <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                        <td>${doc.docType.displayName}</td>
                                        <td><span class="status-badge status-${doc.status}">${doc.status}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise><p class="no-data">진행 중인 문서가 없습니다.</p></c:otherwise>
                </c:choose>
            </div>

            <div style="display: flex; gap: 20px;">
                <div class="widget" style="flex: 1;">
                    <div class="widget-header">
                        <h2>⚠️ 반려 및 취소</h2>
                        <a href="/elecApproval/rejected-or-recalled" class="btn-more">더보기 +</a>
                    </div>
                    <c:choose>
                        <c:when test="${not empty myRejectedOrRecalledDocs}">
                            <table class="data-table">
                                <tbody>
                                    <c:forEach var="doc" items="${myRejectedOrRecalledDocs}" end="2">
                                        <tr>
                                            <td style="text-align: left;">
                                                <a href="/elecApproval/detail/${doc.docId}">
                                                    <span style="color: #dc3545;">[${doc.status eq 'REJECTED' ? '반려' : '취소'}]</span>
                                                    ${doc.title}
                                                </a>
                                            </td>
                                            <td width="80"><fmt:formatDate value="${doc.updatedAt}" pattern="MM-dd"/></td>
                                            <td width="60"><button class="btn btn-secondary" onclick="location.href='/elecApproval/detail/${doc.docId}'">재기안</button></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise><p class="no-data">내역이 없습니다.</p></c:otherwise>
                    </c:choose>
                </div>

                <div class="widget" style="flex: 1;">
                    <div class="widget-header">
                        <h2>✅ 최근 완료 문서</h2>
                        <a href="/elecApproval/approved" class="btn-more">더보기 +</a>
                    </div>
                    <c:choose>
                        <c:when test="${not empty myApprovedDocs}">
                            <table class="data-table">
                                <tbody>
                                    <c:forEach var="doc" items="${myApprovedDocs}" end="2">
                                        <tr>
                                            <td style="text-align: left;">
                                                <a href="/elecApproval/detail/${doc.docId}">${doc.title}</a>
                                            </td>
                                            <td width="100">${doc.docType.displayName}</td>
                                            <td width="80"><fmt:formatDate value="${doc.draftDate}" pattern="MM-dd"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise><p class="no-data">완료된 문서가 없습니다.</p></c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </div>

    <%@ include file="/WEB-INF/modals/formSelectionModal.jsp"%>
    <script type="text/javascript" src="/js/elecApprovalModal.js"></script>
    <script>
        function quickApprove(docId){
            if(!confirm("바로 승인하시겠습니까?")){ return; }
            fetch("/elecApproval/approval/"+docId, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ action: 'APPROVED', comment: '바로 승인' })
            })
            .then(res => {
                if (!res.ok) throw new Error("서버 오류");
                return res.json();
            })
            .then(data => {
                alert(data.message);
                window.location.reload();
            })
            .catch(err => alert('오류 발생: ' + err.message));
        }
    </script>
</body>
</html>z