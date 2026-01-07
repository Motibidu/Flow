<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="${empty document ? '일반 품의서 작성' : '일반 품의서 수정/재기안'}" />

<t:layout title="${pageTitle}">
    <jsp:body>
        <style>
        .content-editor {
            width: 100%;
            height: 500px !important;  /* !important를 붙여서 강제로 높이 적용 */
            padding: 15px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            box-sizing: border-box;
            resize: vertical;          /* 사용자가 마우스로 늘릴 수 있게 설정 */
            line-height: 1.6;
            font-family: inherit;
            font-size: 14px;
        }
</style>
        <link rel="stylesheet" href="/resources/css/approval.css">

        <div class="approval-container">
            <div class="doc-title">${empty document ? '일반 품의서' : '일반 품의서 (재기안)'}</div>

            <div class="approval-table-wrapper">
                <div class="approval-box">
                    <div class="position">기안</div>
                    <div class="name">${empty document ? currentUserName : document.initiatorName}</div>
                    <div class="status">작성중</div>
                </div>
                <c:forEach items="${approvalLines}" var="approvalLine">
                    <div class="approval-box">
                        <div class="position">${approvalLine.position.displayName}</div>
                        <div class="name">&nbsp;</div>
                        <div class="status">대기</div>
                    </div>
                </c:forEach>
            </div>

            <form id="proposalForm">
                <table class="info-table">
                    <tr>
                        <th>문서번호</th>
                        <td>${empty document ? '(자동 채번)' : document.docId}</td>
                        <th>기안일자</th>
                        <td>
                            <c:choose>
                                <c:when test="${empty document}">${draftDate}</c:when>
                                <c:otherwise>
                                    <fmt:formatDate value="${document.draftDate}" pattern="yyyy-MM-dd"/>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>기안부서</th>
                        <td>${empty document ? currentUserDepartment : document.initiatorDepartment}</td>
                        <th>기안자</th>
                        <td>${empty document ? currentUserName : document.initiatorName}</td>
                    </tr>
                    <tr>
                        <th>문서제목</th>
                        <td colspan="3">
                            <input type="text" name="title" id="title" class="form-control" 
                                   placeholder="제목을 입력하세요" required
                                   value="${document.title}">
                        </td>
                    </tr>
                </table>

                <div>
                    <label style="font-weight: bold; display: block; margin-bottom: 8px;">품의 내용</label>
                    <textarea name="content" id="content" class="content-editor" placeholder="품의 내용을 상세히 입력하세요."></textarea>
                </div>

                <input type="hidden" id="jsonContent" name="jsonContent">
                <input type="hidden" id="oldJsonData" value='<c:out value="${document.jsonContent}" escapeXml="false"/>'>

                <div class="btn-group">
                    <button type="button" class="btn btn-cancel" onclick="history.back()">취소</button>
                    
                    <c:if test="${not empty document.docId and document.status eq 'PENDING'}">
                        <button type="button" class="btn btn-recall" onclick="recallDocument(${document.docId})">상신 취소</button>
                    </c:if>

                    <button type="submit" class="btn btn-submit">${empty document ? '결재 상신' : '수정/재기안'}</button>
                </div>
            </form>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function() {
                // 수정/재기안 모드일 경우 기존 데이터 바인딩
                const oldJson = document.getElementById('oldJsonData').value;
                
                if (oldJson && oldJson.trim() !== "") {
                    try {
                        const data = JSON.parse(oldJson);
                        if(data.content) {
                            document.getElementById('content').value = data.content;
                        }
                    } catch (e) {
                        console.error("기존 데이터 파싱 실패:", e);
                    }
                }
            });

            // 상신 취소 로직
            function recallDocument(docId) {
                if(!confirm("정말 상신을 취소하시겠습니까?")) return;
                
                axios.post('/elecApproval/recall/' + docId)
                    .then(res => {
                        alert("상신이 취소되었습니다.");
                        location.href = '/elecApproval';
                    })
                    .catch(err => {
                        console.error(err);
                        alert("취소 중 오류가 발생했습니다.");
                    });
            }

            // 폼 제출 로직
            document.getElementById('proposalForm').addEventListener('submit', function(e) {
                e.preventDefault();
                
                if(!confirm("이대로 결재를 상신하시겠습니까?")) return;

                const proposalDetail = {
                    content: document.getElementById('content').value
                };
                
                const jsonContentStr = JSON.stringify(proposalDetail);
                document.getElementById('jsonContent').value = jsonContentStr;

                const docId = '${document.docId}';
                const url = docId ? '/elecApproval/redraft/' + docId : '/elecApproval/documents';

                const submitData = {
                    title: document.getElementById('title').value,
                    docType: 'GENERAL_PROPOSAL', 
                    jsonContent: jsonContentStr
                };

                axios.post(url, submitData)
                    .then(response => {
                        alert("결재 상신이 완료되었습니다.");
                        location.href = "/elecApproval";
                    })
                    .catch(error => {
                        console.error("상신 에러:", error);
                        const errorMsg = error.response && error.response.data 
                                        ? error.response.data.message 
                                        : "상신 중 오류가 발생했습니다.";
                        alert(errorMsg);
                    });
            });
        </script>
    </jsp:body>
</t:layout>