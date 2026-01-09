<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="${empty document ? '일반 품의서 작성' : '일반 품의서 수정/재기안'}" />

<t:layout title="${pageTitle}">
    <jsp:body>
        
        <%-- 1. CSS 로드 --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/approval.css">

        <style>
            /* [일반 품의서 전용 스타일] */
            .content-editor {
                width: 100%; height: 500px !important; padding: 15px;
                border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box;
                resize: vertical; line-height: 1.6; font-family: inherit; font-size: 14px;
            }
            .btn-sm { padding: 5px 12px; font-size: 12px; border: none; color: white; border-radius: 3px; cursor: pointer; }
            
            /* [동적 결재선 & 모달 스타일] */
            .approval-actions { display: flex; justify-content: flex-end; align-items: center; margin-bottom: 10px; gap: 10px; }
            .btn-line-select { background: #6c757d; color: white; border: none; padding: 5px 15px; border-radius: 4px; cursor: pointer; font-size: 13px; }
            .btn-line-select:hover { background: #5a6268; opacity: 0.9; }
            
            .approval-box { position: relative; cursor: pointer; }
            .approval-box:hover .btn-remove-approver { display: block; }
            .btn-remove-approver {
                display: none; position: absolute; top: -8px; right: -8px;
                width: 20px; height: 20px; background: red; color: white;
                border-radius: 50%; text-align: center; line-height: 18px;
                font-size: 12px; font-weight: bold; border: 1px solid white;
                box-shadow: 0 2px 4px rgba(0,0,0,0.2);
            }

            /* [모달 공통] */
            .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
            .modal-content { background: white; padding: 30px; border-radius: 12px; width: 650px; max-width: 90vw; box-shadow: 0 10px 30px rgba(0,0,0,0.3); }
            .modal-header { font-weight: bold; font-size: 18px; margin-bottom: 15px; border-bottom: 1px solid #ddd; padding-bottom: 10px; display: flex; justify-content: space-between; align-items: center; }
            .modal-footer { margin-top: 15px; text-align: right; }
            
            #orgSearchInput { width: 100%; padding: 12px; font-size: 15px; border: 2px solid #e9ecef; border-radius: 8px; }
            .org-table th { padding: 12px 10px; background: #f8f9fa; border-bottom: 2px solid #dee2e6; font-weight: bold; }
            .user-item-row td { padding: 15px 10px; font-size: 14px; }
            .user-item-row:hover { background-color: #f1f8ff; }
        </style>

        <%-- 3. 본문 컨텐츠 --%>
        <div class="approval-container">
            <div class="doc-title">${empty document ? '일반 품의서' : '일반 품의서 (재기안)'}</div>

            <div class="approval-actions">
                <button type="button" class="btn-line-select" style="background: #17a2b8;" onclick="openMyLineModal()">📂 불러오기</button>
                <button type="button" class="btn-line-select" style="background: #28a745;" onclick="saveMyLine()">💾 저장</button>
                <span style="width: 1px; height: 15px; background: #ccc; margin: 0 5px;"></span>
                <button type="button" class="btn-line-select" onclick="openOrgModal()">+ 결재선 지정</button>
            </div>

            <div class="approval-table-wrapper" id="approvalLineArea">
                <div class="approval-box">
                    <div class="position">기안</div>
                    <div class="name">${empty document ? currentUserName : document.initiatorName}</div>
                    <div class="status">작성중</div>
                </div>
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
                                <c:otherwise><fmt:formatDate value="${document.draftDate}" pattern="yyyy-MM-dd"/></c:otherwise>
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
                    <label style="font-weight: bold; display: block; margin-bottom: 8px; margin-top: 20px;">품의 내용</label>
                    <textarea name="content" id="content" class="content-editor" placeholder="품의 내용을 상세히 입력하세요."></textarea>
                </div>

                <div>
                    <label style="font-weight: bold; display: block; margin-top: 20px; margin-bottom: 8px;">첨부파일</label>
                    <input type="file" id="attachments" name="attachments" class="form-control" multiple>
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

        <div id="orgModal" class="modal-overlay">
            <div class="modal-content">
                <div class="modal-header">
                    <div><span style="font-size: 20px;">결재자 선택</span> <span style="font-size:13px; color:#888;">(직위순 정렬)</span></div>
                    <button type="button" onclick="closeOrgModal()" style="border:none; background:none; font-size:20px; cursor:pointer;">&times;</button>
                </div>
                <div style="margin-bottom: 20px;">
                    <input type="text" id="orgSearchInput" placeholder="이름 검색..." onkeyup="filterUserList()">
                </div>
                <div style="max-height: 400px; overflow-y: auto; border: 1px solid #eee; border-radius: 8px;">
                    <table class="org-table" style="width: 100%; border-collapse: collapse; table-layout: fixed;">
                        <thead style="position: sticky; top: 0; z-index: 1;">
                            <tr>
                                <th style="width: 40%; text-align: left;">이름 / 직위</th>
                                <th style="width: 40%; text-align: left;">부서</th>
                                <th style="width: 20%; text-align: center;">선택</th>
                            </tr>
                        </thead>
                        <tbody id="orgUserList"></tbody>
                    </table>
                </div>
                <div class="modal-footer" style="margin-top: 20px;">
                    <button type="button" class="btn btn-outline" onclick="closeOrgModal()" style="padding: 10px 25px;">닫기</button>
                </div>
            </div>
        </div>

        <div id="myLineModal" class="modal-overlay">
            <div class="modal-content">
                <div class="modal-header">
                    <span style="font-size: 20px;">나의 결재선 불러오기</span>
                    <button type="button" onclick="closeMyLineModal()" style="border:none; background:none; font-size:20px; cursor:pointer;">&times;</button>
                </div>
                <div style="max-height: 400px; overflow-y: auto; border: 1px solid #eee; border-radius: 8px;">
                    <table class="org-table" style="width: 100%; border-collapse: collapse;">
                        <thead style="position: sticky; top: 0; z-index: 1;">
                            <tr>
                                <th style="text-align: left;">결재선 이름</th>
                                <th style="width: 100px; text-align: center;">관리</th>
                                <th style="width: 80px; text-align: center;">선택</th>
                            </tr>
                        </thead>
                        <tbody id="myLineListArea"></tbody>
                    </table>
                </div>
                <div class="modal-footer" style="margin-top: 20px;">
                    <button type="button" class="btn btn-outline" onclick="closeMyLineModal()" style="padding: 10px 25px;">닫기</button>
                </div>
            </div>
        </div>

        <%-- 4. 스크립트 --%>
        <script>
            // [전역 변수]
            let selectedApprovers = [];
            let allOrgUsers = [];
            let mySavedLines = [];

            // [초기화 로직]
            document.addEventListener('DOMContentLoaded', function() {
                // 1. 기존 품의 내용 로드
                const oldJson = document.getElementById('oldJsonData').value;
                if (oldJson && oldJson.trim() !== "") {
                    try {
                        const data = JSON.parse(oldJson);
                        if(data.content) document.getElementById('content').value = data.content;
                    } catch (e) {
                        console.error("JSON Error", e);
                    }
                }

                // 2. 기존 결재선 로드 (재기안 시)
                <c:if test="${not empty approvalLines}">
                    <c:forEach items="${approvalLines}" var="line">
                        selectedApprovers.push({
                            id: "${line.userId}", 
                            name: "${line.userName}", 
                            position: "${line.position.displayName}",
                            department: "${line.department.displayName}"
                        });
                    </c:forEach>
                    renderApprovers(); 
                </c:if>

                // 3. 폼 전송 이벤트
                document.getElementById('proposalForm').addEventListener('submit', handleFormSubmit);
            });

            // =========================
            // [결재선 로직 (공통)]
            // =========================
            function renderApprovers() {
                const area = document.getElementById('approvalLineArea');
                const initiatorBox = area.firstElementChild; 
                area.innerHTML = ''; 
                if(initiatorBox) area.appendChild(initiatorBox);

                selectedApprovers.forEach((user, index) => {
                    const div = document.createElement('div');
                    div.className = 'approval-box';
                    const posName = user.position || '-';
                    div.innerHTML = `
                        <div class="position">\${posName}</div>
                        <div class="name">\${user.name}</div>
                        <div class="status" style="color:#999;">대기</div>
                        <button type="button" class="btn-remove-approver" onclick="removeApprover(\${index})">X</button>
                    `;
                    area.appendChild(div);
                });
            }

            function removeApprover(index) {
                selectedApprovers.splice(index, 1);
                renderApprovers();
            }

            // 조직도 모달
            function openOrgModal() {
                document.getElementById('orgModal').style.display = 'flex';
                if(allOrgUsers.length == 0) {
                    axios.get('/elecApproval/approver-candidates').then(res => {
                        allOrgUsers = res.data;
                        renderUserList(allOrgUsers);
                    });
                } else {
                    renderUserList(allOrgUsers);
                }
            }
            function closeOrgModal() { document.getElementById('orgModal').style.display = 'none'; }
            
            function renderUserList(users) {
                const tbody = document.getElementById('orgUserList');
                if (users.length === 0) { tbody.innerHTML = '<tr><td colspan="3" style="text-align:center;">검색 결과 없음</td></tr>'; return; }
                let html = '';
                users.forEach(u => {
                    const pos = u.positionName || u.position?.displayName || '';
                    const dept = u.departmentName || u.department?.displayName || '';
                    html += `<tr class="user-item-row" onclick="selectUser('\${u.userId}', '\${u.name}', '\${pos}')">
                        <td style="padding:15px;"><span style="font-weight:bold;">\${u.name}</span> <span style="font-size:13px; color:#666;">\${pos}</span></td>
                        <td style="color:#666;">\${dept}</td>
                        <td style="text-align:center;"><button type="button" class="btn-sm" style="background:#007bff;">선택</button></td>
                    </tr>`;
                });
                tbody.innerHTML = html;
            }
            
            function filterUserList() {
                const keyword = document.getElementById('orgSearchInput').value.toLowerCase();
                renderUserList(allOrgUsers.filter(u => (u.name||'').toLowerCase().includes(keyword) || (u.departmentName||'').toLowerCase().includes(keyword)));
            }

            function selectUser(id, name, pos) {
                if(selectedApprovers.some(u => u.id == id)) { alert("이미 추가됨"); return; }
                if(selectedApprovers.length >= 4) { alert("최대 4명"); return; }
                selectedApprovers.push({id, name, position: pos});
                renderApprovers();
                closeOrgModal();
            }

            // 나의 결재선
            function saveMyLine() {
                if(selectedApprovers.length == 0) { alert("결재자를 지정하세요"); return; }
                const title = prompt("결재선 이름:", "나의 결재선");
                if(!title) return;
                axios.post('/elecApproval/my-lines', { title, approverIds: selectedApprovers.map(u=>u.id) })
                     .then(() => alert("저장됨")).catch(() => alert("실패"));
            }

            function openMyLineModal() {
                document.getElementById('myLineModal').style.display = 'flex';
                axios.get('/elecApproval/my-lines').then(res => {
                    mySavedLines = res.data.data;
                    const tbody = document.getElementById('myLineListArea');
                    if(!mySavedLines.length) { tbody.innerHTML = '<tr><td colspan="3">저장된 내역 없음</td></tr>'; return; }
                    let html = '';
                    mySavedLines.forEach(line => {
                        const members = line.approvers.map(p => p.name + " " + p.position.displayName).join(' > ');
                        html += `<tr><td style="padding:15px;"><b>\${line.title}</b><div style="font-size:12px;color:#666;">\${members}</div></td>
                        <td style="text-align:center;"><button onclick="deleteMyLine(\${line.lineId})" style="color:red;border:none;background:none;cursor:pointer;">삭제</button></td>
                        <td style="text-align:center;"><button onclick="loadMyLine(\${line.lineId})" style="background:#17a2b8;color:white;border:none;padding:5px 10px;border-radius:4px;cursor:pointer;">선택</button></td></tr>`;
                    });
                    tbody.innerHTML = html;
                });
            }
            function closeMyLineModal() { document.getElementById('myLineModal').style.display = 'none'; }
            function loadMyLine(id) {
                if(!confirm("적용하시겠습니까?")) return;
                const line = mySavedLines.find(l => l.lineId == id);
                selectedApprovers = line.approvers.map(u => ({ id: u.approverId, name: u.name, position: u.position.displayName }));
                renderApprovers();
                closeMyLineModal();
            }
            function deleteMyLine(id) {
                if(confirm("삭제?")) axios.delete('/elecApproval/my-lines/'+id).then(openMyLineModal);
            }

            function recallDocument(id) {
                if(confirm("취소?")) axios.post('/elecApproval/recall/'+id).then(()=> location.href='/elecApproval');
            }

            // =========================
            // [상신 전송 핸들러]
            // =========================
            function handleFormSubmit(e) {
                e.preventDefault();
                
                if (selectedApprovers.length === 0) { alert("결재자를 지정해주세요."); return; }
                if(!confirm("이대로 결재를 상신하시겠습니까?")) return;

                // 1. JSON 데이터 생성 (일반품의는 content만 있음)
                const proposalDetail = { content: document.getElementById('content').value };
                const jsonStr = JSON.stringify(proposalDetail);
                document.getElementById('jsonContent').value = jsonStr;

                // 2. FormData 생성
                const formData = new FormData();
                formData.append('title', document.getElementById('title').value);
                formData.append('docType', 'GENERAL_PROPOSAL');
                formData.append('jsonContent', jsonStr);
                
                // 결재자 추가
                selectedApprovers.forEach(u => formData.append('approverIds', u.id));
                
                // 파일 추가
                const files = document.getElementById('attachments').files;
                for(let i=0; i<files.length; i++) formData.append('files', files[i]);

                // 3. 전송
                const docId = '${document.docId}';
                const url = docId ? '/elecApproval/documents/' + docId : '/elecApproval/documents';

                axios.post(url, formData, { headers: { 'Content-Type': 'multipart/form-data' } })
                    .then(() => { alert("완료되었습니다."); location.href = "/elecApproval"; })
                    .catch(err => {
                        console.error(err);
                        const msg = err.response && err.response.data ? err.response.data.message : "오류 발생";
                        alert(msg);
                    });
            }
        </script>
    </jsp:body>
</t:layout>