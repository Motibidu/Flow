<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="${empty document ? '지출 결의서 작성' : '지출 결의서 재기안'}" />

<t:layout title="${pageTitle}">
    <jsp:body>
        
        <%-- 1. CSS 로드 --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/approval.css">

        <style>
            /* [지출 결의서 전용 스타일] */
            .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
            .items-table th { border: 1px solid #ddd; padding: 10px; background: #f9f9f9; text-align: center; font-size: 13px; font-weight: 600; }
            .items-table td { border: 1px solid #ddd; padding: 5px; background: #fff; }
            .total-area { margin-top: 20px; padding: 15px; background: #f8f9fa; border: 1px solid #ddd; text-align: right; font-size: 18px; font-weight: bold; color: #1a2a44; }
            .btn-sm { padding: 5px 12px; font-size: 12px; border: none; color: white; border-radius: 3px; cursor: pointer; }
            .btn-add { background: #28a745; }
            .btn-del { background: #dc3545; }
            .text-right { text-align: right; }

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
            <div class="doc-title">${empty document ? '지 출 결 의 서' : '지 출 결 의 서 (재기안)'}</div>

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

            <form id="expenseForm">
                <table class="info-table">
                    <tr>
                        <th>기안자</th>
                        <td>${empty document ? currentUserName : document.initiatorName}</td>
                        <th>기안부서</th>
                        <td>${empty document ? currentUserDepartment : document.initiatorDepartment}</td>
                    </tr>
                    <tr>
                        <th>문서 제목</th>
                        <td colspan="3">
                            <input type="text" name="title" id="title" class="form-control" placeholder="예: 2026년 1월 소모품 구매 비용 청구" required 
                                   value="${empty document ? '2026년 1월 소모품 구매 비용 청구' : document.title}">
                        </td>
                    </tr>
                </table>

                <div style="margin-top: 30px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 5px;">
                        <span style="font-weight: bold; border-left: 4px solid #007bff; padding-left: 10px;">지출 세부 내역</span>
                        <button type="button" class="btn-sm btn-add" onclick="addRow()">+ 항목 추가</button>
                    </div>
                    <table class="items-table" id="expenseItems">
                        <thead>
                            <tr>
                                <th style="width: 140px;">일자</th>
                                <th style="width: 140px;">항목</th>
                                <th>상세내용</th>
                                <th style="width: 140px;">금액</th>
                                <th style="width: 50px;">삭제</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>

                <div class="total-area">
                    총 합계 금액: <span id="totalDisplay">0</span>원
                </div>

                <div style="margin-top: 20px;">
                    <label style="font-weight: bold; display: block; margin-bottom: 5px;">비고 및 특이사항</label>
                    <textarea name="content" id="content" class="form-control" style="min-height: 100px;" placeholder="추가 전달사항이 있으면 입력하세요."></textarea>
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
                    <button type="submit" class="btn btn-submit">${empty document ? '결재 상신' : '재상신'}</button>
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

            // [초기화 로직] - 페이지 로드 시 실행
            document.addEventListener('DOMContentLoaded', function() {
                // 1. 기존 지출내역 로드
                const oldJson = document.getElementById('oldJsonData').value;
                if (oldJson && oldJson.trim() !== "") {
                    try {
                        const data = JSON.parse(oldJson);
                        if(data.remark) document.getElementById('content').value = data.remark;
                        if(data.items && data.items.length > 0) {
                            data.items.forEach(item => addRow(item.date, item.category, item.detail, item.amount));
                        } else {
                            addRow();
                        }
                    } catch (e) {
                        console.error("JSON Error", e);
                        addRow();
                    }
                } else {
                    addRow();
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

                // 3. 폼 전송 이벤트 리스너 등록
                document.getElementById('expenseForm').addEventListener('submit', handleFormSubmit);
            }); 
            // ▲▲▲ [중요] 초기화 끝나는 여기서 닫아줘야 함! ▲▲▲


            // =========================
            // [함수 정의] - 여기부터는 밖으로 나와야 함
            // =========================

            // [지출내역 로직]
            function addRow(date = '', category = '', detail = '', amount = 0) {
                const tbody = document.querySelector('#expenseItems tbody');
                const newRow = document.createElement('tr');
                const displayAmount = amount == 0 ? 0 : amount;
                newRow.innerHTML = `
                    <td><input type="date" class="form-control item-date" value="\${date}" required></td>
                    <td><input type="text" class="form-control item-category" placeholder="식대 등" value="\${category}"></td>
                    <td><input type="text" class="form-control item-detail" placeholder="내용" value="\${detail}"></td>
                    <td><input type="number" class="form-control item-amount text-right" onkeyup="calculateTotal()" onchange="calculateTotal()" value="\${displayAmount}"></td>
                    <td style="text-align: center;"><button type="button" class="btn-sm btn-del" onclick="deleteRow(this)">X</button></td>
                `;
                tbody.appendChild(newRow);
                calculateTotal();
            }

            function deleteRow(btn) {
                const rows = document.querySelectorAll('#expenseItems tbody tr');
                if (rows.length > 1) { btn.closest('tr').remove(); calculateTotal(); }
                else { alert("최소 1개 행이 필요합니다."); }
            }

            function calculateTotal() {
                let total = 0;
                document.querySelectorAll('.item-amount').forEach(input => total += Number(input.value) || 0);
                document.getElementById('totalDisplay').innerText = total.toLocaleString();
                return total;
            }

            // [결재선 로직]
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

            // 상신 취소
            function recallDocument(id) {
                if(confirm("취소?")) axios.post('/elecApproval/recall/'+id).then(()=> location.href='/elecApproval');
            }

            // [상신 전송 핸들러]
            function handleFormSubmit(e) {
                e.preventDefault();
                if (selectedApprovers.length === 0) { alert("결재자를 지정해주세요."); return; }
                if(!confirm("상신하시겠습니까?")) return;

                const items = [];
                document.querySelectorAll('#expenseItems tbody tr').forEach(row => {
                    items.push({
                        date: row.querySelector('.item-date').value,
                        category: row.querySelector('.item-category').value,
                        detail: row.querySelector('.item-detail').value,
                        amount: row.querySelector('.item-amount').value
                    });
                });
                const jsonStr = JSON.stringify({ items, totalAmount: calculateTotal(), remark: document.getElementById('content').value });
                document.getElementById('jsonContent').value = jsonStr;

                const formData = new FormData();
                formData.append('title', document.getElementById('title').value);
                formData.append('docType', 'EXPENSE_REPORT');
                formData.append('jsonContent', jsonStr);
                selectedApprovers.forEach(u => formData.append('approverIds', u.id));
                
                const files = document.getElementById('attachments').files;
                for(let i=0; i<files.length; i++) formData.append('files', files[i]);

                const docId = '${document.docId}';
                const url = docId ? '/elecApproval/documents/' + docId : '/elecApproval/documents';
                axios.post(url, formData, { headers: { 'Content-Type': 'multipart/form-data' } })
                     .then(() => { alert("완료되었습니다."); location.href = "/elecApproval"; })
                     .catch(err => { console.error(err); alert("오류 발생"); });
            }
        </script>
    </jsp:body>
</t:layout>