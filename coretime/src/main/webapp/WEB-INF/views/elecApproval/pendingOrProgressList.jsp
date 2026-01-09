<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="진행 중인 문서">
    <link rel="stylesheet" href="/resources/css/list.css">
    <div class="main">
            <h1>📤 내가 기안한 진행 중 문서</h1>
            
            <div class="widget">
                <table class="data-table">
                    <colgroup>
                        <col width="8%"> <col width="*"> <col width="15%"> <col width="15%"> <col width="10%">
                    </colgroup>
                    <thead>
                        <tr>
                            <th>NO</th> <th>제목</th> <th>기안일</th> <th>양식</th> <th>현재 상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty docList}">
                                <c:forEach var="doc" items="${docList}">
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
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="5" class="no-data">진행 중인 문서가 없습니다.</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination -->
                <nav aria-label="Page navigation" style="margin-top: 20px;">
                    <ul class="pagination justify-content-center">
                        <c:if test="${pageInfo.hasPreviousPage}">
                            <li class="page-item">
                                <a class="page-link" href="?page=${pageInfo.prePage}&size=${pageInfo.pageSize}">이전</a>
                            </li>
                        </c:if>
                        <c:forEach begin="${pageInfo.navigateFirstPage}" end="${pageInfo.navigateLastPage}" var="pageNum">
                            <li class="page-item ${pageNum == pageInfo.pageNum ? 'active' : ''}">
                                <a class="page-link" href="?page=${pageNum}&size=${pageInfo.pageSize}">${pageNum}</a>
                            </li>
                        </c:forEach>
                        <c:if test="${pageInfo.hasNextPage}">
                            <li class="page-item">
                                <a class="page-link" href="?page=${pageInfo.nextPage}&size=${pageInfo.pageSize}">다음</a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
            </div>
            <div style="text-align: right; margin-top: 20px;">
                <button class="btn btn-outline" onclick="location.href='/elecApproval'">← 대시보드로 돌아가기</button>
            </div>
        </div>
</t:layout>