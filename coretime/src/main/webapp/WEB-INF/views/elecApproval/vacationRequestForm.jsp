<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<t:layout title="${empty document ? '휴가 신청서 작성' : '휴가 신청서 수정/재기안'}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/approval.css">
    
    <style>
        textarea.form-control { height: 150px; resize: vertical; line-height: 1.5; }
        
        /* [동적 결재선 전용 스타일] */
        .approval-actions { display: flex; justify-content: flex-end; align-items: center; margin-bottom: 10px; gap: 10px; }
        .btn-line-select { background: #6c757d; color: white; border: none; padding: 5px 15px; border-radius: 4px; cursor: pointer; font-size: 13px; }
        .btn-line-select:hover { background: #5a6268; opacity: 0.9; }
        
        /* 결재박스 삭제 버튼 (X) */
        .approval-box { position: relative; cursor: pointer; }
        .approval-box:hover .btn-remove-approver { display: block; }
        .btn-remove-approver {
            display: none; position: absolute; top: -8px; right: -8px;
            width: 20px; height: 20px; background: red; color: white;
            border-radius: 50%; text-align: center; line-height: 18px;
            font-size: 12px; font-weight: bold; border: 1px solid white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        /* [모달 공통 스타일] */
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { 
            background: white; 
            padding: 30px;            
            border-radius: 12px; 
            width: 650px;             
            max-width: 90vw;          
            box-shadow: 0 10px 30px rgba(0,0,0,0.3); 
        }

        .modal-header { font-weight: bold; font-size: 18px; margin-bottom: 15px; border-bottom: 1px solid #ddd; padding-bottom: 10px; display: flex; justify-content: space-between; align-items: center; }
        .modal-footer { margin-top: 15px; text-align: right; }

        /* 검색창 디자인 */
        #orgSearchInput {
            width: 100%; padding: 12px; font-size: 15px;
            border: 2px solid #e9ecef; border-radius: 8px; transition: border-color 0.2s;
        }
        #orgSearchInput:focus { border-color: #007bff; outline: none; }

        /* 테이블 스타일 */
        .org-table th { padding: 12px 10px; background: #f8f9fa; border-bottom: 2px solid #dee2e6; font-weight: bold; }
        .user-item-row td { padding: 15px 10px; font-size: 14px; }
        .user-item-row:hover { background-color: #f1f8ff; }
    </style>

    <div class="approval-container">
        <div class="doc-title">${empty document ? '휴 가 신 청 서' : '휴 가 신 청 서 (재기안)'}</div>

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

        <form id="vacationForm">
            <table class="info-table">
                <tr>
                    <th>기안자</th>
                    <td>${empty document ? currentUserName : document.initiatorName}</td>
                    <th>기안부서</th>
                    <td>${empty document ? currentUserDepartment : document.initiatorDepartment}</td>
                </tr>
                <tr>
                    <th>문서제목</th>
                    <td colspan="3">
                        <input type="text" name="title" id="title" class="form-control" 
                               placeholder="예: [휴가신청] 00팀 000 연차 신청의 건" required 
                               value="${empty document ? '[휴가신청] '.concat(currentUserName).concat(' 연차 신청의 건') : document.title}">
                    </td>
                </tr>
            </table>

            <div style="margin-top: 30px;">
                <h4 style="font-size: 16px; border-left: 4px solid #007bff; padding-left: 10px; margin-bottom: 15px; color: #333;">신청 내역</h4>
                <table class="info-table">
                    <tr>
                        <th>휴가 종류</th>
                        <td>
                            <select name="vacationType" id="vacationType" class="form-control" required>
                                <option value="">-- 선택하세요 --</option>
                                <option value="연차">연차</option>
                                <option value="반차">반차</option>
                                <option value="병가">병가</option>
                                <option value="경조사">경조사</option>
                                <option value="기타">기타</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>신청 기간</th>
                        <td>
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <input type="date" name="startDate" id="startDate" class="form-control" style="flex: 1;" required>
                                <span>~</span>
                                <input type="date" name="endDate" id="endDate" class="form-control" style="flex: 1;" required>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>신청 사유</th>
                        <td>
                            <textarea name="reason" id="reason" class="form-control" placeholder="구체적인 사유를 입력하세요."></textarea>
                        </td>
                    </tr>
                    <tr>
                        <th>비상 연락처</th>
                        <td>
                            <input type="text" name="contactInfo" id="contactInfo" class="form-control" 
                                   placeholder="예: 010-0000-0000" 
                                   value="${empty document ? '010-' : ''}">
                        </td>
                    </tr>
                    <tr>
                        <th>첨부파일</th>
                        <td>
                            <input type="file" id="attachments" name="attachments" class="form-control" multiple>
                        </td>
                    </tr>
                </table>
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
                <div>
                    <span style="font-size: 20px;">결재자 선택</span>
                    <span style="font-size:13px; font-weight:normal; color:#888; margin-left:10px;">(직위순 정렬)</span>
                </div>
                <button type="button" onclick="closeOrgModal()" style="border:none; background:none; font-size:20px; cursor:pointer;">&times;</button>
            </div>
            
            <div style="margin-bottom: 20px;">
                <input type="text" id="orgSearchInput" placeholder="이름 또는 부서명을 입력하여 검색하세요..." onkeyup="filterUserList()">
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

    <script>
    // [전역 변수]
    let selectedApprovers = [];
    let allOrgUsers = [];

    document.addEventListener('DOMContentLoaded', function() {
        // A. 기존 폼 데이터 로드
        const oldJson = document.getElementById('oldJsonData').value;
        if (oldJson && oldJson.trim() !== "") {
            try {
                const data = JSON.parse(oldJson);
                if(data.vacationType) document.getElementById('vacationType').value = data.vacationType;
                if(data.startDate) document.getElementById('startDate').value = data.startDate;
                if(data.endDate) document.getElementById('endDate').value = data.endDate;
                if(data.reason) document.getElementById('reason').value = data.reason;
                if(data.contactInfo) document.getElementById('contactInfo').value = data.contactInfo;
            } catch (e) { console.error("데이터 파싱 실패", e); }
        }

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
    });

    // -------------------------------------------------------------
    // [기능 1] 메인 화면 렌더링
    // -------------------------------------------------------------
    function renderApprovers() {
        const area = document.getElementById('approvalLineArea');
        const initiatorBox = area.firstElementChild; 
        area.innerHTML = ''; 
        if(initiatorBox) area.appendChild(initiatorBox);

        selectedApprovers.forEach((user, index) => {
            const div = document.createElement('div');
            div.className = 'approval-box';
            
            const posName = user.position || '-';
            const userName = user.name || '미지정';

            div.innerHTML = `
                <div class="position">\${posName}</div>
                <div class="name">\${userName}</div>
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

    // -------------------------------------------------------------
    // [기능 2] 조직도 모달 (결재자 추가)
    // -------------------------------------------------------------
    function openOrgModal() {
        document.getElementById('orgModal').style.display = 'flex';
        document.getElementById('orgSearchInput').value = ''; 
        document.getElementById('orgSearchInput').focus();

        if (allOrgUsers.length > 0) {
            renderUserList(allOrgUsers);
            return;
        }

        // 전체 유저 조회 API
        axios.get('/elecApproval/approver-candidates') 
            .then(res => {
                allOrgUsers = res.data; 
                renderUserList(allOrgUsers);
            })
            .catch(err => {
                console.error(err);
                document.getElementById('orgUserList').innerHTML = '<tr><td colspan="3" style="text-align:center; padding:20px; color:red;">목록 로드 실패</td></tr>';
            });
    }

    function closeOrgModal() { document.getElementById('orgModal').style.display = 'none'; }

    function renderUserList(users) {
        const tbody = document.getElementById('orgUserList');
        if (users.length === 0) {
            tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; padding:20px; color:#999;">검색 결과가 없습니다.</td></tr>';
            return;
        }

        let html = '';
        users.forEach(user => {
            const positionName = user.positionName || (user.position && user.position.displayName) || user.position || '';
            const deptName = user.departmentName || (user.department && user.department.displayName) || user.department || '';

            html += `
                <tr class="user-item-row" 
                    onclick="selectUser('\${user.userId}', '\${user.name}', '\${positionName}')" 
                    style="border-bottom: 1px solid #f2f2f2; cursor: pointer;">
                    
                    <td style="padding: 15px 10px;">
                        <span style="font-weight: bold; font-size: 15px;">\${user.name}</span> 
                        <span style="color: #495057; margin-left: 5px; font-size:13px;">\${positionName}</span>
                    </td>
                    
                    <td style="padding: 15px 10px; color: #666;">\${deptName}</td>
                    
                    <td style="padding: 15px 10px; text-align: center;" onclick="event.stopPropagation();">
                        <button type="button" class="btn-sm" 
                                onclick="selectUser('\${user.userId}', '\${user.name}', '\${positionName}')"
                                style="background:#007bff; color:white; border:none; padding:6px 12px; border-radius:6px; cursor:pointer;">
                            선택
                        </button>
                    </td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    }

    function filterUserList() {
        const keyword = document.getElementById('orgSearchInput').value.toLowerCase();
        const filtered = allOrgUsers.filter(user => {
            const uName = user.name ? user.name.toLowerCase() : '';
            const uDept = user.departmentName ? user.departmentName.toLowerCase() : '';
            return uName.includes(keyword) || uDept.includes(keyword);
        });
        renderUserList(filtered);
    }
    
    function selectUser(id, name, position) {
        if(selectedApprovers.some(u => u.id == id)) {
            alert("이미 추가된 결재자입니다.");
            return;
        }
        if(selectedApprovers.length >= 4) {
            alert("결재자는 최대 4명까지만 지정 가능합니다.");
            return;
        }
        selectedApprovers.push({ id: id, name: name, position: position });
        renderApprovers();
        closeOrgModal();
    }

    // -------------------------------------------------------------
    // [기능 3] 나의 결재선 (저장 & 불러오기)
    // -------------------------------------------------------------
    
    // 3-1. 현재 결재선 저장
    function saveMyLine() {
        if (selectedApprovers.length === 0) {
            alert("저장할 결재자가 없습니다. 최소 1명 이상 지정해주세요.");
            return;
        }

        const title = prompt("이 결재선을 어떤 이름으로 저장하시겠습니까?", "나의 결재선");
        if (!title) return;

        // API 전송용 데이터 (제목 + ID 배열)
        const payload = {
            title: title,
            approverIds: selectedApprovers.map(u => u.id)
        };

        axios.post('/elecApproval/my-lines', payload)
            .then(res => alert("저장되었습니다."))
            .catch(err => {
                console.error(err);
                alert("저장 중 오류가 발생했습니다. (로그인 여부 및 API 주소를 확인하세요)");
            });
    }

    // 3-2. 불러오기 모달 열기 (목록 조회)
    function openMyLineModal() {
        document.getElementById('myLineModal').style.display = 'flex';
        
        axios.get('/elecApproval/my-lines')
            .then(res => {
                console.log("res: ", res);
                const lines = res.data.data;
                
                // [★핵심] 나중에 쓰기 위해 전역 변수에 저장해둡니다!
                mySavedLines = lines; 

                const tbody = document.getElementById('myLineListArea');
                
                if (!lines || lines.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; padding:20px;">저장된 결재선이 없습니다.</td></tr>';
                    return;
                }

                let html = '';
                lines.forEach(line => {
                    // 명단 텍스트 생성
                    let memberStr = '';
                    if (line.approvers && line.approvers.length > 0) {
                        memberStr = line.approvers
                            .map(p => `\${p.name} \${p.position.displayName}`)
                            .join(' <span style="color:#ccc">▶</span> ');
                    }

                    html += `
                        <tr class="user-item-row" style="border-bottom: 1px solid #eee;">
                            <td style="padding: 15px 10px;">
                                <div style="font-weight:bold; font-size:15px; margin-bottom:4px;">\${line.title}</div>
                                <div style="font-size: 12px; color: #666; display:flex; align-items:center; flex-wrap:wrap; gap:5px;">\${memberStr}</div>
                            </td>
                            <td style="padding: 15px 10px; text-align: center;">
                                <button type="button" onclick="deleteMyLine(\${line.lineId})" style="color:red; background:none; border:none; cursor:pointer;">삭제</button>
                            </td>
                            <td style="padding: 15px 10px; text-align: center;">
                                <button type="button" onclick="loadMyLine(\${line.lineId})" 
                                    style="background:#17a2b8; color:white; border:none; padding:6px 12px; border-radius:6px; cursor:pointer;">
                                    불러오기
                                </button>
                            </td>
                        </tr>
                    `;
                });
                tbody.innerHTML = html;
            })
            .catch(err => {
                console.error(err);
                alert("목록 로드 실패");
            });
    }

    function closeMyLineModal() { document.getElementById('myLineModal').style.display = 'none'; }

    // 3-3. 특정 결재선 불러와서 적용
    function loadMyLine(lineId) {
        if (!confirm("현재 결재자가 모두 삭제되고, 선택한 결재선으로 교체됩니다.")) return;

        const foundLine = mySavedLines.find(line => line.lineId == lineId);

        if (!foundLine) {
            alert("데이터를 찾을 수 없습니다. 다시 시도해주세요.");
            return;
        }

        // 찾은 데이터로 화면 갱신
        selectedApprovers = [];
        if (foundLine.approvers) {
            foundLine.approvers.forEach(user => {
                selectedApprovers.push({
                    id: user.approverId,
                    name: user.name,
                    position: user.position.displayName
                });
            });
        }

        renderApprovers();
        closeMyLineModal();
    }

    // 3-4. 결재선 삭제
    function deleteMyLine(lineId) {
        if (!confirm("정말 삭제하시겠습니까?")) return;
        
        axios.delete('/elecApproval/my-lines/' + lineId)
            .then(res => {
                alert("삭제되었습니다.");
                // 목록 다시 로드 (모달 닫았다 다시 열 필요 없이 갱신)
                openMyLineModal(); 
            })
            .catch(err => alert("삭제 실패"));
    }


    // -------------------------------------------------------------
    // [기능 4] 최종 상신
    // -------------------------------------------------------------
    document.getElementById('vacationForm').addEventListener('submit', function(e) {
        e.preventDefault();

        if (selectedApprovers.length === 0) {
            alert("최소 1명 이상의 결재자를 지정해야 합니다.");
            return;
        }

        if(!confirm("결재를 상신하시겠습니까?")) return;

        const vacationDetail = {
            vacationType: document.getElementById('vacationType').value,
            startDate: document.getElementById('startDate').value,
            endDate: document.getElementById('endDate').value,
            reason: document.getElementById('reason').value,
            contactInfo: document.getElementById('contactInfo').value
        };
        const jsonContentStr = JSON.stringify(vacationDetail);
        document.getElementById('jsonContent').value = jsonContentStr;

        const approverIds = selectedApprovers.map(u => u.id);
        const docId = '${document.docId}';
        const url = (docId && docId !== '') ? '/elecApproval/redraft/' + docId : '/elecApproval/documents';

        const formData = new FormData();
        formData.append('title', document.getElementById('title').value);
        formData.append('docType', 'VACATION_REQUEST');
        formData.append('jsonContent', jsonContentStr);
        
        approverIds.forEach(id => formData.append('approverIds', id));

        const fileInput = document.getElementById('attachments');
        for (let i = 0; i < fileInput.files.length; i++) {
            formData.append('files', fileInput.files[i]);
        }

        axios.post(url, formData, { headers: { 'Content-Type': 'multipart/form-data' } })
            .then(res => {
                alert("정상적으로 처리되었습니다.");
                location.href = "/elecApproval";
            })
            .catch(err => {
                console.error(err);
                const errorMsg = err.response && err.response.data ? err.response.data.message : "오류가 발생했습니다.";
                alert(errorMsg);
            });
    });

    function recallDocument(docId) {
        if(!confirm("정말 상신을 취소하시겠습니까?")) return;
        axios.post('/elecApproval/recall/' + docId)
            .then(res => { alert("상신이 취소되었습니다."); location.href = '/elecApproval'; })
            .catch(err => { console.error(err); alert("취소 중 오류가 발생했습니다."); });
    }
    </script>
</t:layout>