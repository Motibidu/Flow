<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<c:set var="pageTitle" value="${empty document ? '지출 결의서 작성' : '지출 결의서 재기안'}" />

<t:layout title="${pageTitle}">
    <jsp:body>
        
        <%-- 1. CSS 로드 --%>
        <link rel="stylesheet" href="/resources/css/approval.css">

        <%-- 2. 지출 결의서 전용 스타일 (approval.css에 없는 것들) --%>
        <style>
            /* [지출 내역 테이블 스타일] */
            .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
            .items-table th { border: 1px solid #ddd; padding: 10px; background: #f9f9f9; text-align: center; font-size: 13px; font-weight: 600; }
            .items-table td { border: 1px solid #ddd; padding: 5px; background: #fff; }

            /* [합계 영역 스타일] */
            .total-area { margin-top: 20px; padding: 15px; background: #f8f9fa; border: 1px solid #ddd; text-align: right; font-size: 18px; font-weight: bold; color: #1a2a44; }

            /* [작은 버튼 (행 추가/삭제용)] */
            .btn-sm { padding: 5px 12px; font-size: 12px; border: none; color: white; border-radius: 3px; cursor: pointer; }
            .btn-add { background: #28a745; }
            .btn-del { background: #dc3545; }

            /* [유틸리티] */
            .text-right { text-align: right; }
        </style>

        <%-- 3. 본문 컨텐츠 --%>
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
                    
                    <c:if test="${not empty document.docId and document.status eq 'PENDING'}">
                        <button type="button" class="btn btn-recall" onclick="recallDocument(${document.docId})">상신 취소</button>
                    </c:if>

                    <button type="submit" class="btn btn-submit">${empty document ? '결재 상신' : '재상신'}</button>
                </div>
            </form>
        </div>

        <%-- 4. 스크립트 --%>
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                // 수정/재기안 모드: 기존 데이터 로드
                const oldJson = document.getElementById('oldJsonData').value;
                
                if (oldJson && oldJson.trim() !== "") {
                    try {
                        const data = JSON.parse(oldJson);
                        if(data.remark) document.getElementById('content').value = data.remark;
                        if(data.items && data.items.length > 0) {
                            data.items.forEach(item => {
                                addRow(item.date, item.category, item.detail, item.amount);
                            });
                        } else {
                            addRow();
                        }
                    } catch (e) {
                        console.error("JSON 로드 실패", e);
                        addRow();
                    }
                } else {
                    addRow(); // 신규 작성 시 빈 줄 1개
                }
            });

            // 행 추가
            function addRow(date = '', category = '', detail = '', amount = 0) {
                const tbody = document.querySelector('#expenseItems tbody');
                const newRow = document.createElement('tr');
                const displayAmount = amount == 0 ? 0 : amount;

                // JS Template Literal 내의 EL 표현식 충돌 방지를 위해 역슬래시(\) 사용
                newRow.innerHTML = `
                    <td><input type="date" class="form-control item-date" value="\${date}" required></td>
                    <td><input type="text" class="form-control item-category" placeholder="식대, 비품 등" value="\${category}"></td>
                    <td><input type="text" class="form-control item-detail" placeholder="내용 입력" value="\${detail}"></td>
                    <td><input type="number" class="form-control item-amount text-right" onkeyup="calculateTotal()" onchange="calculateTotal()" value="\${displayAmount}"></td>
                    <td style="text-align: center;"><button type="button" class="btn-sm btn-del" onclick="deleteRow(this)">X</button></td>
                `;
                tbody.appendChild(newRow);
                calculateTotal();
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
                document.querySelectorAll('.item-amount').forEach(input => {
                    total += Number(input.value) || 0;
                });
                document.getElementById('totalDisplay').innerText = total.toLocaleString();
                return total;
            }

            // 상신 취소
            function recallDocument(docId) {
                if(!confirm("정말 상신을 취소하시겠습니까?")) return;
                
                // axios는 layout에 포함되어 있음
                axios.post('/elecApproval/recall/' + docId)
                    .then(res => {
                        alert("상신이 취소되었습니다.");
                        location.href = '/elecApproval';
                    })
                    .catch(err => {
                        console.error(err);
                        alert("취소 처리 중 오류가 발생했습니다.");
                    });
            }

            // 폼 전송
            document.getElementById('expenseForm').addEventListener('submit', function(e) {
                e.preventDefault();
                
                if(!confirm("지출 결의서를 상신하시겠습니까?")) return;

                const items = [];
                document.querySelectorAll('#expenseItems tbody tr').forEach(row => {
                    items.push({
                        date: row.querySelector('.item-date').value,
                        category: row.querySelector('.item-category').value,
                        detail: row.querySelector('.item-detail').value,
                        amount: row.querySelector('.item-amount').value
                    });
                });

                const expenseDetail = {
                    items: items,
                    totalAmount: calculateTotal(),
                    remark: document.getElementById('content').value
                };
                const jsonContentStr = JSON.stringify(expenseDetail);
                document.getElementById('jsonContent').value = jsonContentStr;

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
    </jsp:body>
</t:layout>