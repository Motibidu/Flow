<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${empty document ? '일반 품의서 작성' : '일반 품의서 수정/재기안'}</title>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <style>
        /* ----- 공통 스타일 (A4 용지 느낌) ----- */
        body { font-family: 'Malgun Gothic', '맑은 고딕', sans-serif; background-color: #f4f7f6; color: #333; margin: 0; padding: 20px; }
        
        .approval-container { width: 850px; margin: 30px auto; background: #fff; padding: 50px; border: 1px solid #ddd; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .doc-title { text-align: center; font-size: 32px; font-weight: bold; text-decoration: underline; margin-bottom: 40px; color: #1a2a44; }

        /* 결재선 박스 */
        .approval-table-wrapper { display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 30px; }
        .approval-box { border: 1px solid #000; text-align: center; width: 110px; background-color: #fff; }
        .approval-box .position { background-color: #f2f2f2; padding: 5px; border-bottom: 1px solid #000; font-weight: bold; font-size: 12px; }
        .approval-box .name { padding: 15px 5px; font-weight: 600; font-size: 14px; min-height: 40px; display: flex; align-items: center; justify-content: center; }
        .approval-box .status { font-size: 11px; color: #666; border-top: 1px dashed #ddd; padding: 5px; background: #fafafa; }

        /* 정보 테이블 */
        .info-table { width: 100%; border-collapse: collapse; margin-bottom: 25px; }
        .info-table th { width: 140px; border: 1px solid #ddd; padding: 12px; background: #f9f9f9; text-align: left; font-weight: 600; color: #495057; }
        .info-table td { border: 1px solid #ddd; padding: 10px; background-color: #fff; }

        /* 입력 컨트롤 */
        .form-control { width: 100%; padding: 8px 10px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; font-family: inherit; font-size: 14px; }
        .form-control:read-only { background-color: #e9ecef; color: #495057; }
        
        /* 본문 에디터 스타일 */
        .content-editor { width: 100%; min-height: 400px; padding: 15px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; resize: vertical; line-height: 1.6; font-family: inherit; font-size: 14px; }

        /* 버튼 그룹 */
        .btn-group { text-align: center; margin-top: 40px; display: flex; justify-content: center; gap: 12px; }
        .btn { padding: 12px 30px; border-radius: 4px; cursor: pointer; font-weight: bold; border: 1px solid #ccc; font-size: 15px; }
        .btn-submit { background: #007bff; color: white; border: none; }
        .btn-cancel { background: #fff; color: #333; }
        .btn-recall { background: #dc3545; color: white; border: none; }
    </style>
</head>
<body>

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
                            <c:when test="${empty document}">
                                ${draftDate}
                            </c:when>
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
                
                <%-- 상신 취소: 수정 모드이고 상태가 PENDING일 때만 표시 --%>
                <c:if test="${not empty document.docId and document.status eq 'PENDING'}">
                    <button type="button" class="btn btn-recall" onclick="recallDocument(${document.docId})">상신 취소</button>
                </c:if>

                <button type="submit" class="btn btn-submit">${empty document ? '결재 상신' : '수정/재기안'}</button>
            </div>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 1. 수정/재기안 모드일 경우 기존 데이터 바인딩
            const oldJson = document.getElementById('oldJsonData').value;
            
            if (oldJson && oldJson.trim() !== "") {
                try {
                    const data = JSON.parse(oldJson);
                    // 일반 품의서는 content 필드 하나만 매핑하면 됨
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

        // 폼 제출 로직 (신규/수정 공통)
        document.getElementById('proposalForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            if(!confirm("이대로 결재를 상신하시겠습니까?")) return;

            // 1. JSON 데이터 구성
            const proposalDetail = {
                content: document.getElementById('content').value
            };
            
            const jsonContentStr = JSON.stringify(proposalDetail);
            document.getElementById('jsonContent').value = jsonContentStr;

            // 2. 요청 URL 및 데이터 분기 처리
            const docId = '${document.docId}';
            const url = docId ? '/elecApproval/redraft/' + docId : '/elecApproval/documents';

            // ★ 중요: Controller에서 @RequestBody로 받기 위해 docType 포함
            const submitData = {
                title: document.getElementById('title').value,
                docType: 'GENERAL_PROPOSAL', 
                jsonContent: jsonContentStr
            };

            // 3. Axios 전송
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
</body>
</html>