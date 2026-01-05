<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${empty document ? '지출 결의서 작성' : '지출 결의서 재기안'}</title>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <style>
        /* ----- 공통 스타일 ----- */
        body { font-family: 'Malgun Gothic', '맑은 고딕', sans-serif; background-color: #f4f7f6; color: #333; margin: 0; padding: 20px; }
        
        /* 문서 컨테이너 (A4 느낌) */
        .approval-container { width: 850px; margin: 30px auto; background: #fff; padding: 50px; border: 1px solid #ddd; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .doc-title { text-align: center; font-size: 32px; font-weight: bold; text-decoration: underline; margin-bottom: 40px; color: #1a2a44; }

        /* 상단 결재선 박스 */
        .approval-table-wrapper { display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 30px; }
        .approval-box { border: 1px solid #000; text-align: center; width: 110px; background-color: #fff; }
        .approval-box .position { background-color: #f2f2f2; padding: 5px; border-bottom: 1px solid #000; font-weight: bold; font-size: 12px; }
        .approval-box .name { padding: 15px 5px; font-weight: 600; font-size: 14px; min-height: 40px; display: flex; align-items: center; justify-content: center; }
        .approval-box .status { font-size: 11px; color: #666; border-top: 1px dashed #ddd; padding: 5px; background: #fafafa; }

        /* 정보 테이블 */
        .info-table { width: 100%; border-collapse: collapse; margin-bottom: 25px; }
        .info-table th { width: 140px; border: 1px solid #ddd; padding: 12px; background: #f9f9f9; text-align: left; font-weight: 600; color: #495057; }
        .info-table td { border: 1px solid #ddd; padding: 10px; background-color: #fff; }

        /* 지출 항목 테이블 */
        .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .items-table th { border: 1px solid #ddd; padding: 10px; background: #f9f9f9; text-align: center; font-size: 13px; font-weight: 600; }
        .items-table td { border: 1px solid #ddd; padding: 5px; background: #fff; }

        /* 입력 컨트롤 스타일 */
        .form-control { width: 100%; padding: 8px 10px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; font-family: inherit; font-size: 14px; }
        .form-control:read-only { background-color: #e9ecef; color: #495057; }
        .text-right { text-align: right; }
        
        /* 합계 영역 */
        .total-area { margin-top: 20px; padding: 15px; background: #f8f9fa; border: 1px solid #ddd; text-align: right; font-size: 18px; font-weight: bold; color: #1a2a44; }

        /* 버튼 그룹 */
        .btn-group { text-align: center; margin-top: 40px; display: flex; justify-content: center; gap: 12px; }
        .btn { padding: 12px 30px; border-radius: 4px; cursor: pointer; font-weight: bold; border: 1px solid #ccc; font-size: 15px; }
        .btn-submit { background: #007bff; color: white; border: none; }
        .btn-cancel { background: #fff; color: #333; }
        
        /* 소형 버튼 (추가/삭제) */
        .btn-sm { padding: 5px 12px; font-size: 12px; border: none; color: white; border-radius: 3px; cursor: pointer; }
        .btn-add { background: #28a745; }
        .btn-del { background: #dc3545; }
    </style>
</head>
<body>

    <div class="approval-container">
        <div class="doc-title">${empty document ? '지 출 결 의 서' : '지 출 결 의 서 (재기안)'}</div>

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
                               value="${document.title}">
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
                    <tbody>
                    </tbody>
                </table>
            </div>

            <div class="total-area">
                총 합계 금액: <span id="totalDisplay">0</span>원
            </div>

            <div style="margin-top: 20px;">
                <label style="font-weight: bold; display: block; margin-bottom: 8px;">비고 및 특이사항</label>
                <textarea name="content" id="content" class="form-control" style="min-height: 100px;" placeholder="추가 전달사항이 있으면 입력하세요."></textarea>
            </div>

            <input type="hidden" id="jsonContent" name="jsonContent">
            <input type="hidden" id="oldJsonData" value='<c:out value="${document.jsonContent}" escapeXml="false"/>'>

            <div class="btn-group">
                <button type="button" class="btn btn-cancel" onclick="history.back()">취소</button>
                <button type="submit" class="btn btn-submit">${empty document ? '결재 상신' : '재상신'}</button>
            </div>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 1. 수정/재기안 모드: 기존 JSON 데이터가 있으면 로드
            const oldJson = document.getElementById('oldJsonData').value;
            
            if (oldJson && oldJson.trim() !== "") {
                try {
                    const data = JSON.parse(oldJson);
                    
                    // (1) 비고란 채우기
                    if(data.remark) document.getElementById('content').value = data.remark;

                    // (2) 지출 항목 행 생성
                    if(data.items && data.items.length > 0) {
                        data.items.forEach(item => {
                            addRow(item.date, item.category, item.detail, item.amount);
                        });
                    } else {
                        addRow(); // 데이터는 있는데 항목이 없으면 빈 줄 1개
                    }
                } catch (e) {
                    console.error("JSON 로드 실패", e);
                    addRow(); // 에러 시 기본 빈 줄
                }
            } else {
                // 2. 신규 작성 모드: 빈 줄 1개 생성
                addRow();
            }
        });

        // 행 추가 함수 (매개변수 없으면 빈 값)
        function addRow(date = '', category = '', detail = '', amount = 0) {
            const tbody = document.querySelector('#expenseItems tbody');
            const newRow = document.createElement('tr');
            
            // 금액이 0이면 화면에 빈칸으로 보일지, 0으로 보일지 결정 (여기선 0 표시)
            const displayAmount = amount == 0 ? 0 : amount;

            newRow.innerHTML = `
                <td><input type="date" class="form-control item-date" value="\${date}" required></td>
                <td><input type="text" class="form-control item-category" placeholder="식대, 비품 등" value="\${category}"></td>
                <td><input type="text" class="form-control item-detail" placeholder="내용 입력" value="\${detail}"></td>
                <td><input type="number" class="form-control item-amount text-right" onkeyup="calculateTotal()" onchange="calculateTotal()" value="\${displayAmount}"></td>
                <td style="text-align: center;"><button type="button" class="btn-sm btn-del" onclick="deleteRow(this)">X</button></td>
            `;
            tbody.appendChild(newRow);
            calculateTotal(); // 행 추가 시 합계 갱신 (초기 로드 시 필요)
        }

        // 행 삭제
        function deleteRow(btn) {
            const rows = document.querySelectorAll('#expenseItems tbody tr');
            if (rows.length > 1) {
                btn.closest('tr').remove();
                calculateTotal();
            } else {
                alert("최소 한 개의 내역은 있어야 합니다.");
            }
        }

        // 합계 계산
        function calculateTotal() {
            let total = 0;
            const amounts = document.querySelectorAll('.item-amount');
            amounts.forEach(input => {
                total += Number(input.value) || 0;
            });
            document.getElementById('totalDisplay').innerText = total.toLocaleString();
            return total;
        }

        // 폼 전송
        document.getElementById('expenseForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            if(!confirm("지출 결의서를 상신하시겠습니까?")) return;

            // 1. 지출 내역 리스트 생성
            const items = [];
            const rows = document.querySelectorAll('#expenseItems tbody tr');
            rows.forEach(row => {
                items.push({
                    date: row.querySelector('.item-date').value,
                    category: row.querySelector('.item-category').value,
                    detail: row.querySelector('.item-detail').value,
                    amount: row.querySelector('.item-amount').value
                });
            });

            // 2. JSON 데이터 구성
            const expenseDetail = {
                items: items,
                totalAmount: calculateTotal(),
                remark: document.getElementById('content').value
            };
            const jsonContentStr = JSON.stringify(expenseDetail);
            document.getElementById('jsonContent').value = jsonContentStr;

            // 3. 서버 전송 (Axios)
            const docId = '${document.docId}';
            const url = docId ? '/elecApproval/redraft/' + docId : '/elecApproval/documents';

            const submitData = {
                title: document.getElementById('title').value,
                docType: 'EXPENSE_REPORT',
                jsonContent: jsonContentStr
            };

            axios.post(url, submitData)
                .then(response => {
                    alert("상신이 완료되었습니다.");
                    location.href = "/elecApproval";
                })
                .catch(error => {
                    console.error("상신 에러:", error);
                    alert("처리 중 오류가 발생했습니다.");
                });
        });
    </script>
</body>
</html>