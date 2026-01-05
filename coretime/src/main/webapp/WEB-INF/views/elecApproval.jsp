<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>전자결재 시스템</title>

<style>
    /* ----- 기본 및 레이아웃 ----- */
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
        padding: 20px;
        margin-bottom: 25px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }

    .widget h2 {
        font-size: 18px;
        color: #1a2a44;
        margin-top: 0;
        margin-bottom: 20px;
    }

    /* ----- 버튼 스타일 ----- */
    .action-buttons {
        margin-bottom: 20px;
    }
    
    .btn {
        padding: 8px 15px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-weight: 500;
        transition: background-color 0.2s, box-shadow 0.2s;
    }

    .btn-primary {
        background-color: #007bff;
        color: white;
    }
    .btn-primary:hover {
        background-color: #0056b3;
        box-shadow: 0 2px 5px rgba(0, 123, 255, 0.3);
    }

    .btn-secondary {
        background-color: #6c757d;
        color: white;
        font-size: 12px;
        padding: 6px 12px;
    }
    .btn-secondary:hover {
        background-color: #5a6268;
    }

    /* ----- 테이블 스타일 ----- */
    .data-table {
        width: 100%;
        border-collapse: collapse;
        text-align: center;
    }

    .data-table th, .data-table td {
        padding: 12px 10px;
        border-bottom: 1px solid #e9ecef;
    }

    .data-table thead th {
        background-color: #f8f9fa;
        color: #495057;
        font-weight: 600;
        border-top: 1px solid #dee2e6;
        border-bottom-width: 2px;
    }
    
    .data-table tbody tr:hover {
        background-color: #f1f3f5;
    }
    
    .data-table td:nth-child(2) { /* 제목 컬럼 */
        text-align: left;
    }

    .data-table a {
        color: #0056b3;
        text-decoration: none;
        font-weight: 500;
    }
    .data-table a:hover {
        text-decoration: underline;
    }
    
    /* ----- 상태 배지 스타일 ----- */
    .status-badge {
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 600;
        color: #fff;
        text-transform: uppercase;
    }
    .status-APPROVED { background-color: #28a745; }
    .status-REJECTED { background-color: #dc3545; }
    .status-RECALLED { background-color: #6c757d; } /* 회수 상태는 회색 계열 추천 */
    .status-PENDING { background-color: #ffc107; color: #212529; }
    .status-IN_PROGRESS { background-color: #17a2b8; }

    /* 데이터 없을 때 메시지 */
    .no-data {
        text-align: center;
        padding: 40px;
        color: #868e96;
    }

    /* 1. 모달 전체 배경 (Overlay) */
    .modal {
        display: none;        /* 초기에는 숨김 */
        position: fixed;     /* 화면에 고정 */
        z-index: 9999;       /* 최상단에 배치 */
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5); /* 어두운 반투명 배경 */
        
        /* 중앙 정렬을 위한 설정 */
        justify-content: center;
        align-items: center;
    }

    /* 2. 모달 하얀색 박스 (Content) */
    .modal-content {
        background-color: #fff;
        width: 600px;        /* 적절한 너비 설정 */
        max-width: 90%;      /* 모바일 대응 */
        border-radius: 10px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        display: flex;
        flex-direction: column; /* 헤더-바디-푸터 세로 배치 */
        overflow: hidden;    /* 둥근 테두리 밖으로 내용 안나가게 */
    }

    /* 3. 내부 레이아웃 디테일 */
    .modal-header {
        padding: 15px 20px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .modal-body {
        padding: 20px;
        max-height: 70vh;    /* 내용이 너무 많으면 스크롤 생성 */
        overflow-y: auto;
    }

    .modal-footer {
        padding: 15px 20px;
        border-top: 1px solid #eee;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }

    /* 닫기 버튼 스타일 */
    .modal-close-button {
        font-size: 24px;
        cursor: pointer;
        color: #999;
    }
    .modal-close-button:hover { color: #333; }

    .form-select-grid {
    display: grid;
    grid-template-columns: 1fr 1fr; /* 2단 구성 */
    gap: 20px;
    }

    .form-section {
        border: 1px solid #f0f0f0;
        padding: 15px;
        border-radius: 6px;
    }

    .form-section__title {
        font-size: 15px;
        margin-bottom: 10px;
        color: #007bff;
        border-left: 3px solid #007bff;
        padding-left: 8px;
    }

    .form-detail-info p {
        margin: 8px 0;
        font-size: 13px;
    }

    /* 모달 스타일 생략 (기존 스타일 유지) */
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
            <h1>전자결재 시스템</h1>

            <div class="action-buttons">
                <button class="btn btn-primary" onclick="openFormSelectionModal()">새 결재 진행</button>
            </div>

            <%-- 1. 결재 대기 문서 (관리자용) --%>
            
            <div class="widget">
                <h2>나의 결재 대기 문서</h2>
                <c:choose>
                    <c:when test="${not empty pendingApprovals}">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>문서 ID</th>
                                    <th>제목</th>
                                    <th>결재양식</th>
                                    <th>기안자</th>
                                    <th>기안일</th>
                                    <th>상태</th>
                                    <th>액션</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${pendingApprovals}">
                                    <tr>
                                        <td>${doc.docId}</td>
                                        <td><a href="/elecApproval/detail/${doc.docId}">${doc.title}</a></td>
                                        <td>${doc.docType.displayName}</td>
                                        <td>${doc.initiatorName}</td>
                                        <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                        <td><span class="status-badge status-${doc.status}">${doc.status}</span></td>
                                        <td><button class="btn btn-secondary" onclick="quickApprove(${doc.docId})">바로결재</button></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">결재할 문서가 없습니다.</p>
                    </c:otherwise>
                </c:choose>
            </div>
            

            <%-- 2. 내가 기안한 진행 중 문서 --%>
            <div class="widget">
                <h2>내가 기안한 진행 중 문서</h2>
                <c:choose>
                    <c:when test="${not empty myInProgressDocs}">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>문서 ID</th>
                                    <th>제목</th>
                                    <th>기안일</th>
                                    <th>결재양식</th>
                                    <th>상태</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${myInProgressDocs}">
                                    <tr>
                                        <td>${doc.docId}</td>
                                        <td><a href="/elecApproval/detail/${doc.docId}">${doc.title}</a></td>
                                        <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                        <td>${doc.docType.displayName}</td>
                                        <td><span class="status-badge status-${doc.status}">${doc.status}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">현재 진행 중인 기안 문서가 없습니다.</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="widget">
                <h2>반려 및 취소된 문서</h2>
                <c:choose>
                    <c:when test="${not empty myRejectedOrRecalledDocs}">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>문서 ID</th>
                                    <th>제목</th>
                                    <th>상태 변화일</th>
                                    <th>결재양식</th>
                                    <th>구분</th>
                                    <th>관리</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${myRejectedOrRecalledDocs}">
                                    <tr>
                                        <td>${doc.docId}</td>
                                        <td><a href="/elecApproval/detail/${doc.docId}">${doc.title}</a></td>
                                        <td><fmt:formatDate value="${doc.updatedAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                        <td>${doc.docType.displayName}</td>
                                        <td>
                                            <span class="status-badge status-${doc.status}">
                                                ${doc.status eq 'REJECTED' ? '반려' : '취소'}
                                            </span>
                                        </td>
                                        <td>
                                            <button class="btn btn-secondary" onclick="location.href='/elecApproval/detail/${doc.docId}'">재기안</button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">반려되거나 취소된 문서가 없습니다.</p>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="widget">
                <h2>최종 승인된 문서</h2>
                <c:choose>
                    <c:when test="${not empty myApprovedDocs}">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>문서 ID</th>
                                    <th>제목</th>
                                    <th>기안일</th>
                                    <th>결재양식</th>
                                    <th>결재상태</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="doc" items="${myApprovedDocs}">
                                    <tr>
                                        <td>${doc.docId}</td>
                                        <td><a href="/elecApproval/detail/${doc.docId}">${doc.title}</a></td>
                                        <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                        <td>${doc.docType.displayName}</td>
                                        <td><span class="status-badge status-${doc.status}">${doc.status}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <p class="no-data">완료된 문서가 없습니다.</p>
                    </c:otherwise>
                </c:choose>
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
            .then(response => {
                if (!response.ok) return response.json().then(error => { throw new Error(error.message); });
                return response.json();
            })
            .then(data => {
                alert(data.message);
                window.location.reload();
            })
            .catch(error => {
                alert('승인 처리 중 오류 발생: ' + error.message);
            });
        }
    </script>
</body>
</html>