<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="대리 결재자 설정">
    <jsp:body>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/approval.css">

        <style>
            /* 페이지 전체 레이아웃 */
            .substitute-container {
                width: 850px;
                background: #fff;
                padding: 50px;
                border: 1px solid #ddd;
                box-shadow: 0 4px 15px rgba(0,0,0,0.05);
                margin: 0 auto;
            }

            .page-title {
                text-align: center;
                font-size: 32px;
                font-weight: bold;
                text-decoration: underline;
                margin-bottom: 20px;
                color: #1a2a44;
            }

            .page-description {
                text-align: center;
                color: #666;
                font-size: 14px;
                margin-bottom: 40px;
                padding: 10px;
                background: #f8f9fa;
                border-radius: 4px;
            }

            /* 폼 섹션 */
            .form-section {
                margin-bottom: 40px;
            }

            .section-title {
                font-size: 18px;
                font-weight: bold;
                border-left: 4px solid #007bff;
                padding-left: 10px;
                margin-bottom: 20px;
                color: #333;
            }

            /* 폼 테이블 스타일 - approval.css의 info-table 스타일 재사용 */
            .form-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 25px;
            }

            .form-table th {
                width: 140px;
                border: 1px solid #ddd;
                padding: 12px;
                background: #f9f9f9;
                text-align: left;
                font-weight: 600;
                color: #495057;
            }

            .form-table td {
                border: 1px solid #ddd;
                padding: 10px;
                background-color: #fff;
            }

            .date-group {
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .date-group input {
                flex: 1;
            }

            /* 버튼 스타일 통일 */
            .btn-add {
                background: #007bff;
                color: white;
                border: none;
                padding: 12px 30px;
                border-radius: 4px;
                cursor: pointer;
                font-weight: bold;
                font-size: 15px;
                transition: all 0.2s;
            }

            .btn-add:hover {
                background: #0056b3;
            }

            .btn-delete {
                background: #dc3545;
                color: white;
                border: none;
                padding: 6px 12px;
                border-radius: 4px;
                cursor: pointer;
                font-size: 13px;
                transition: all 0.2s;
            }

            .btn-delete:hover {
                background: #c82333;
            }

            /* 리스트 테이블 */
            .list-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 15px;
            }

            .list-table thead th {
                background: #f9f9f9;
                border: 1px solid #ddd;
                padding: 12px;
                font-weight: 600;
                color: #495057;
                text-align: center;
            }

            .list-table tbody td {
                border: 1px solid #ddd;
                padding: 12px;
                text-align: center;
            }

            .list-table tbody tr:hover {
                background-color: #f1f8ff;
            }

            .empty-row {
                color: #999;
                padding: 30px !important;
            }
        </style>

        <div class="substitute-container">
            <div class="page-title">대 리 결 재 자 설 정</div>
            <div class="page-description">
                부재 시 나를 대신하여 결재할 사람을 지정합니다.
            </div>

            <div class="form-section">
                <h4 class="section-title">새 대리 결재자 추가</h4>
                <table class="form-table">
                    <tr>
                        <th>대리 결재자</th>
                        <td>
                            <select id="substituteId" class="form-control">
                                <option value="">-- 선택하세요 --</option>
                                <c:forEach var="user" items="${allUsers}">
                                    <c:if test="${user.id ne pageContext.request.userPrincipal.name}">
                                        <option value="${user.id}">${user.name} (${user.id})</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>대리 기간</th>
                        <td>
                            <div class="date-group">
                                <input type="date" id="startDate" class="form-control">
                                <span>~</span>
                                <input type="date" id="endDate" class="form-control">
                            </div>
                        </td>
                    </tr>
                </table>
                <div style="text-align: center;">
                    <button class="btn-add" onclick="addSubstitute()">추가</button>
                </div>
            </div>

            <div class="form-section">
                <h4 class="section-title">현재 지정된 대리 결재자</h4>
                <table class="list-table">
                    <thead>
                        <tr>
                            <th style="width: 35%;">대리 결재자</th>
                            <th style="width: 25%;">대리 시작일</th>
                            <th style="width: 25%;">대리 종료일</th>
                            <th style="width: 15%;">관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty substituteApprovals}">
                                <c:forEach var="sub" items="${substituteApprovals}">
                                    <tr>
                                        <td>${sub.substituteName} (${sub.substituteId})</td>
                                        <td><fmt:formatDate value="${sub.startDate}" pattern="yyyy-MM-dd"/></td>
                                        <td><fmt:formatDate value="${sub.endDate}" pattern="yyyy-MM-dd"/></td>
                                        <td>
                                            <button class="btn-delete" onclick="deleteSubstitute(${sub.id})">삭제</button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="empty-row">지정된 대리 결재자가 없습니다.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <script>
            function addSubstitute() {
                const substituteId = document.getElementById('substituteId').value;
                const startDate = document.getElementById('startDate').value;
                const endDate = document.getElementById('endDate').value;

                if (!substituteId || !startDate || !endDate) {
                    alert("모든 필드를 입력해주세요.");
                    return;
                }
                
                if (new Date(startDate) > new Date(endDate)) {
                    alert("시작일은 종료일보다 늦을 수 없습니다.");
                    return;
                }

                if(!confirm("정말 추가하시겠습니까?")) return;

                axios.post('/users/substitute-approvals', {
                    substituteId: substituteId,
                    startDate: startDate,
                    endDate: endDate
                })
                .then(function (response) {
                    alert("대리 결재자가 추가되었습니다.");
                    location.reload();
                })
                .catch(function (error) {
                    alert("오류가 발생했습니다: " + (error.response.data.message || error.message));
                });
            }

            function deleteSubstitute(id) {
                if (!confirm("이 대리 결재자 지정을 삭제하시겠습니까?")) {
                    return;
                }

                axios.delete('/users/substitute-approvals/' + id)
                .then(function (response) {
                    alert("삭제되었습니다.");
                    location.reload();
                })
                .catch(function (error) {
                    alert("오류가 발생했습니다: " + (error.response.data.message || error.message));
                });
            }
        </script>
    </jsp:body>
</t:layout>
