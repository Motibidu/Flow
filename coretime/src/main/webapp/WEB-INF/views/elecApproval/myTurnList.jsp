<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="내가 결재할 문서">
    <link rel="stylesheet" href="/resources/css/list.css">
    <div class="main">
        <h1>📥 내가 결재할 문서</h1>
        
        <div class="widget">
            <table class="data-table">
                <colgroup>
                    <col width="8%"> <col width="10%"> <col width="*"> <col width="10%"> <col width="15%"> <col width="15%"> <col width="10%">
                </colgroup>
                <thead>
                    <tr>
                        <th>NO</th> <th>문서종류</th> <th>제목</th> <th>기안자</th> <th>기안부서</th> <th>기안일시</th> <th>상태</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty docList}">
                            <c:forEach var="doc" items="${docList}">
                                <tr>
                                    <td>${doc.docId}</td>
                                    <td>${doc.docType.displayName}</td>
                                    <td style="text-align: left; padding-left: 20px;">
                                        <a href="/elecApproval/detail/${doc.docId}">${doc.title}</a>
                                    </td>
                                    <td>${doc.initiatorName}</td>
                                    <td>${doc.initiatorDepartment}</td>
                                    <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                    <td><span class="status-badge status-${doc.status}">${doc.status.displayName}</span></td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="7" class="no-data">결재할 문서가 없습니다.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

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
        <div class="d-flex justify-content-center">
            <div class="input-group w-50">
                <select class="form-select" id="searchType" style="width: 15%;">
                    <option value="title">제목</option>
                    <option value="doc_id">문서번호</option>
                </select>
                <input type="text" class="form-control" id="searchKeyword" placeholder="검색어를 입력하세요" style="width: 70%;">
                <button class="btn btn-primary" onclick="searchDocs()" style="width: 15%;">검색</button>
            </div>
        </div>
        <div style="text-align: right; margin-top: 20px;">
            <button class="btn btn-outline" onclick="location.href='/elecApproval'">← 대시보드로 돌아가기</button>
        </div>
    </div>
    <script>
        function searchDocs() {
            const searchType = document.getElementById('searchType').value;
            const keyword = document.getElementById('searchKeyword').value;
            
            const url = new URL(window.location.href);
            url.searchParams.set('page', '1');
            url.searchParams.set('searchType', searchType);
            url.searchParams.set('keyword', keyword);
            
            window.location.href = url.toString();
        }
    </script>
</t:layout>
