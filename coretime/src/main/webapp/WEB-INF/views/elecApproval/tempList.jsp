<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="임시 저장함">
    <link rel="stylesheet" href="/resources/css/list.css">
    <div class="main">
        <h1>💾 임시 저장 문서</h1>
        
        <div class="widget">
            <table class="data-table">
                <colgroup>
                    <col width="8%"> <col width="*"> <col width="15%"> <col width="15%"> <col width="10%">
                </colgroup>
                <thead>
                    <tr>
                        <th>NO</th> <th>제목</th> <th>저장일</th> <th>양식</th> <th>상태</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty docList}">
                            <c:forEach var="doc" items="${docList}">
                                <tr>
                                    <td>${doc.docId}</td>
                                    <td style="text-align: left; padding-left: 15px;">
                                        <a href="/elecApproval/redraft/${doc.docId}">${doc.title}</a>
                                    </td>
                                    <td><fmt:formatDate value="${doc.draftDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                    <td>${doc.docType.displayName}</td>
                                    <td><span class="status-badge status-${doc.status}">${doc.status}</span></td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="5" class="no-data">임시 저장된 문서가 없습니다.</td></tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
        <div style="text-align: right; margin-top: 20px;">
            <button class="btn btn-outline" onclick="location.href='/elecApproval'">← 대시보드로 돌아가기</button>
        </div>
    </div>
</t:layout>
