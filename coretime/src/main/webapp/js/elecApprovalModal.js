// --- 모달 관련 JavaScript ---

// DOMContentLoaded 이벤트 리스너를 사용하여 문서가 완전히 로드된 후 스크립트 실행
// 이 리스너 안에서 DOM 요소들을 찾아야 합니다.
document.addEventListener('DOMContentLoaded', function () {
    // 모달 DOM 요소들 가져오기
    const formSelectionModal = document.getElementById('formSelectionModal');
    const confirmFormSelectionButton = document.getElementById('confirmFormSelection');
    const radioButtons = document.querySelectorAll('input[name="selectedForm"]');
    const detailTitle = document.getElementById('detailTitle');
    const detailGlobalDoc = document.getElementById('detailGlobalDoc');
    const detailRetentionPeriod = document.getElementById('detailRetentionPeriod');
    const detailDraftingDept = document.getElementById('detailDraftingDept');
    const detailDeptDoc = document.getElementById('detailDeptDoc');

    // 양식 상세 정보 mock 데이터
    const formDetails = {
        "vacationRequestForm": {
            title: "휴가신청서",
            globalDoc: "인사기록",
            retentionPeriod: "10년",
            draftingDept: "인사팀",
            deptDoc: "인사팀 문서함"
        },
        "품의서": {
            title: "품의서",
            globalDoc: "경영기록",
            retentionPeriod: "5년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "출장보고서": {
            title: "출장보고서",
            globalDoc: "업무기록",
            retentionPeriod: "3년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "출장": {
            title: "출장신청서",
            globalDoc: "업무기록",
            retentionPeriod: "3년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "국내출장신청": {
            title: "국내출장신청서",
            globalDoc: "업무기록",
            retentionPeriod: "3년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "해외출장신청": {
            title: "해외출장신청서",
            globalDoc: "업무기록",
            retentionPeriod: "3년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "비자발급신청": {
            title: "비자발급신청서",
            globalDoc: "인사기록",
            retentionPeriod: "5년",
            draftingDept: "인사팀",
            deptDoc: "인사팀 문서함"
        },
        "교육결과보고": {
            title: "교육결과보고서",
            globalDoc: "교육기록",
            retentionPeriod: "1년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "휴직원": {
            title: "휴직원",
            globalDoc: "인사기록",
            retentionPeriod: "10년",
            draftingDept: "인사팀",
            deptDoc: "인사팀 문서함"
        },
        "재분류신청": {
            title: "재분류신청서",
            globalDoc: "업무기록",
            retentionPeriod: "3년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "교육수강신청": {
            title: "교육수강신청서",
            globalDoc: "교육기록",
            retentionPeriod: "1년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        },
        "일반": {
            title: "일반품의",
            globalDoc: "경영기록",
            retentionPeriod: "1년",
            draftingDept: "기안 부서",
            deptDoc: "기안 부서 문서함"
        }
    };

    // 모달 열기 함수 (전역에서 호출 가능하도록 window 객체에 연결)
    window.openFormSelectionModal = function() {
        console.log("openFormSelectionModal");
        if (formSelectionModal) { // null 체크 추가
            formSelectionModal.style.display = 'flex'; // flex로 설정하여 중앙 정렬 적용
            console.log("openFormSelectionModal called and modal displayed.");
        } else {
            console.error("Error: formSelectionModal element not found during open attempt.");
        }
    };

    // 모달 닫기 함수 (전역에서 호출 가능하도록 window 객체에 연결)
    window.closeFormSelectionModal = function() {
        if (formSelectionModal) { // null 체크 추가
            formSelectionModal.style.display = 'none';
            console.log("closeFormSelectionModal called.");
        } else {
            console.error("Error: formSelectionModal element not found for closing attempt.");
        }
    };

    // 라디오 버튼 변경 이벤트 리스너
    radioButtons.forEach(radio => {
        radio.addEventListener('change', function() {
            const selectedFormType = this.value;
            const details = formDetails[selectedFormType];
            if (details) {
                detailTitle.textContent = details.title;
                detailGlobalDoc.textContent = details.globalDoc;
                detailRetentionPeriod.textContent = details.retentionPeriod;
                detailDraftingDept.textContent = details.draftingDept;
                detailDeptDoc.textContent = details.deptDoc;
            } else {
                detailTitle.textContent = '';
                detailGlobalDoc.textContent = '';
                detailRetentionPeriod.textContent = '';
                detailDraftingDept.textContent = '';
                detailDeptDoc.textContent = '';
            }
        });
    });

    // "확인" 버튼 클릭 시
    confirmFormSelectionButton.addEventListener('click', function() {
        const selectedRadio = document.querySelector('input[name="selectedForm"]:checked');
        if (selectedRadio) {
            const selectedFormValue = selectedRadio.value;
            alert("선택된 양식: " + selectedFormValue + ". 새 문서 작성 페이지로 이동합니다.");
            window.location.href = '/elecApproval/new?formType=' + encodeURIComponent(selectedFormValue);
        } else {
            alert("결재 양식을 선택해주세요.");
        }
    });

    // 모달 외부 클릭 시 닫기 (선택 사항)
    window.addEventListener('click', function(event) {
        if (event.target == formSelectionModal) {
            closeFormSelectionModal();
        }
    });
});