<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<script>
    console.log("SSE Notification System Loaded");

    // 전역 변수로 선언하여 모든 함수에서 접근 가능하게 합니다.
    let userId, dropdown, listContainer;

    document.addEventListener("DOMContentLoaded", function() {
        userId = "${currentUserId}";
        const bell = document.getElementById('notif-bell');
        dropdown = document.getElementById('notif-dropdown');
        listContainer = document.getElementById('notif-list-container');

        if (userId && userId !== "") {
            // 1. SSE 연결 생성
            const eventSource = new EventSource('/api/notifications/subscribe?userId=' + userId);

            // 2. 서버에서 보낸 'notification' 이벤트 수신
            eventSource.addEventListener("notification", function(event) {
                const data = JSON.parse(event.data);
                console.log("data: ", data);
                showToast(data.notifId, data.message, data.targetUrl);

                const badge = document.getElementById('notif-badge');
                if (badge) badge.style.display = 'block';
                
                if (dropdown.style.display === 'block') {
                    loadNotifications(); 
                }
            });

            eventSource.addEventListener("connect", function(event) {
                console.log("SSE 연결 성공");
            });

            eventSource.onerror = function(error) {
                console.error("SSE 연결 에러:", error);
            };
        }

        // 1. 종 클릭 시 목록 토글
        if (bell) {
            bell.onclick = function(e) {
                e.stopPropagation(); 
                const isVisible = dropdown.style.display === 'block';
                
                if (!isVisible) {
                    loadNotifications(); 
                    dropdown.style.display = 'block';
                } else {
                    dropdown.style.display = 'none';
                }
            };
        }

        // 2. 외부 클릭 시 닫기
        document.addEventListener('click', function() {
            if (dropdown) dropdown.style.display = 'none';
        });
    }); // DOMContentLoaded 끝 (괄호 체크 완료)

    // 3. 서버에서 알림 목록 가져오기
    function loadNotifications() {
        if (!userId) return;
        
        fetch('/api/notifications/recent-notifications?userId=' + userId)
            .then(res => res.json())
            .then(data => {
                listContainer.innerHTML = ''; 
                
                if (data.length === 0) {
                    listContainer.innerHTML = '<div class="notif-empty">알림이 없습니다.</div>';
                    return;
                }

                data.forEach(item => {
                    const div = document.createElement('div');
                    div.className = 'notif-item' + (item.isRead === 'UNREAD' ? ' unread' : '');
                    div.innerHTML = 
                        
                        '<div class="notif-item-msg">' + 
                            '<span class="notif-item-id">' + item.notifId + '</span>. ' + item.message + 
                        '</div>' +
                        '<div class="notif-item-title">제목: ' + item.title + '</div>'+
                        '<div class="notif-item-date">' + formatDate(item.createdAt) + '</div>';
                    
                    // 클릭 시 로직 수정
                    div.onclick = function() {
                        if (item.isRead === 'UNREAD') {
                            // 1. 아직 안 읽은 알림이라면 서버에 읽음 처리 요청
                            fetch('/api/notifications/mark-read?notifId=' + item.notifId, { method: 'POST' })
                                .then(res => {
                                    if (res.ok) {
                                        // 2. 읽음 처리 성공 시 페이지 이동
                                        if (item.targetUrl) location.href = item.targetUrl;
                                    }
                                })
                                .catch(err => console.error("읽음 처리 실패:", err));
                        } else {
                            // 3. 이미 읽은 알림이라면 바로 이동
                            if (item.targetUrl) location.href = item.targetUrl;
                        }
                    };
                    listContainer.appendChild(div);
                });
            })
            .catch(err => console.error("알림 로드 실패:", err));
    }

    function formatDate(dateStr) {
        if (!dateStr) return "";
        const date = new Date(dateStr);
        return (date.getMonth() + 1) + "월 " + date.getDate() + "일 "+ date.getHours() + "시 " + date.getMinutes() + "분";
    }

    function showToast(notifId, message, targetUrl) {
        let container = document.getElementById('notification-container');
        if (!container) return;

        // 1. 토스트 컨테이너 생성
        const toast = document.createElement('div');
        toast.className = 'notif-toast';

        // 2. 닫기 버튼 생성
        const closeBtn = document.createElement('span');
        closeBtn.className = 'toast-close-btn';
        closeBtn.innerHTML = '&times;'; // '×' 기호

        // 3. 닫기 버튼 클릭 이벤트 (이벤트 전파 차단 필수)
        closeBtn.onclick = function(e) {
            e.stopPropagation(); // 부모(toast)의 onclick 이벤트가 실행되지 않게 함
            removeToast(toast);
        };

        // 4. 메시지 영역 생성
        const msgContent = document.createElement('div');
        msgContent.className = 'notif-message';
        msgContent.innerHTML = notifId+". "+message;

        // 5. 토스트 조립
        toast.appendChild(closeBtn);
        toast.appendChild(msgContent);

        // 6. 토스트 전체 클릭 시 이동 (닫기 버튼 클릭 시에는 실행 안 됨)
        toast.onclick = function() {
            fetch('/api/notifications/mark-read?notifId=' + notifId, { method: 'POST' })
                    .then(res => {
                        if (res.ok && targetUrl) location.href = targetUrl;
                    });
        };

        container.appendChild(toast);

        // 7. 10초 뒤 자동 삭제
        setTimeout(() => {
            if (toast.parentNode) removeToast(toast);
        }, 10000);
    }

    // 공통 토스트 제거 함수 (애니메이션 포함)
    function removeToast(toastElement) {
        toastElement.style.opacity = '0';
        toastElement.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (toastElement.parentNode) toastElement.remove();
        }, 500);
    }
</script>
<style>
        .header {
		width: 100%;
		height: 80px; /* 고정 높이 */
		display: flex;
		align-items: center; /* 수직 중앙 정렬 */
		background-color: #f8f9fa; /* 밝은 회색 배경 */
		padding: 0 30px; /* 좌우 패딩 추가 */
	}

	.header__logout{
		margin-left: auto;
		margin-right: 50px;		
	}

	.header__logo{
		max-width: 200px;
	}

	.user-info {
		font-weight: bold; /* 굵은 글씨 */
		color: #343a40; /* 어두운 글씨색 */
		font-size: 1.1em; /* 약간 크게 */
		margin-right: 15px;
	}

	/* notifications */
	/* 알림 컨테이너 */
	#notification-container {
	position: fixed;
	top: 20px;
	right: 20px;
	z-index: 9999;
	}

	/* 개별 알림 스타일 */
	.notif-toast {
	background-color: #ffffff;
	border-left: 5px solid #007bff; /* 파란색 강조선 */
	box-shadow: 0 4px 12px rgba(0,0,0,0.15);
	padding: 15px 20px;
	margin-bottom: 10px;
	border-radius: 4px;
	min-width: 250px;
	cursor: pointer;
	transition: transform 0.3s ease;
	animation: slideIn 0.5s ease-out;
	}

	.notif-toast:hover {
	transform: translateY(-3px);
	}

	.notif-title {
        font-weight: bold;
        font-size: 14px;
        margin-bottom: 5px;
        color: #333;
	}

	.notif-message {
        font-size: 13px;
        color: #666;
	}

	/* 애니메이션 효과 */
	@keyframes slideIn {
	from { transform: translateX(100%); opacity: 0; }
	to { transform: translateX(0); opacity: 1; }
	}

	.notif-wrapper { position: relative; display: inline-block; margin-right: 20px; }
	.notif-bell-container { position: relative; }
	.notif-badge {
	position: absolute; top: 0; right: 0;
	width: 10px; height: 10px;
	background-color: red; border-radius: 50%; border: 2px solid white;
	}
	.notif-dropdown {
	position: absolute; top: 40px; right: 0;
	width: 300px; background: white; border: 1px solid #ddd;
	box-shadow: 0 4px 10px rgba(0,0,0,0.1); border-radius: 8px; z-index: 1000;
	}
	.notif-header { padding: 10px; border-bottom: 1px solid #eee; font-weight: bold; font-size: 0.9rem; }
	.notif-footer { display: block; text-align: center; padding: 10px; font-size: 0.8rem; color: #007bff; text-decoration: none; border-top: 1px solid #eee; }
	.notif-item { padding: 12px 15px; border-bottom: 1px solid #f9f9f9; cursor: pointer; transition: background 0.2s; }
	.notif-item:hover { background-color: #f0f7ff; }
	.notif-item.unread { background-color: #fcfcfc; border-left: 3px solid #007bff; }
	.notif-item-msg { font-size: 0.85rem; color: #333; margin-bottom: 3px; }
    .notif-item-title { font-size: 0.85rem; color: #333; margin-bottom: 3px; }
	.notif-item-date { font-size: 0.75rem; color: #999; }
	.notif-empty { padding: 20px; text-align: center; color: #999; font-size: 0.85rem; }

    /* 토스트 내 닫기 버튼 스타일 */
    .notif-toast {
        position: relative !important; /* 부모 요소는 반드시 relative여야 합니다 */
        padding-right: 35px !important; /* X 버튼이 들어갈 공간 확보 */
        }

    .toast-close-btn {
        position: absolute !important;
        top: 5px !important;
        right: 10px !important;
        font-size: 22px !important; /* 크기 키움 */
        font-weight: bold !important;
        color: #333 !important; /* 더 진한 색상으로 변경 */
        cursor: pointer !important;
        line-height: 1 !important;
        z-index: 10001 !important; /* 다른 요소보다 위에 오도록 설정 */
    }

    .toast-close-btn:hover {
        color: #ff0000 !important; /* 마우스 올리면 빨간색으로 변경 */
    }
</style>
        <header class= "header">
		<a href="/" class="header__logo-link">
			<img class= "header__logo" src= "/resources/images/FlowLogo.png"/>
		</a>
		<form class= "header__logout" action="/logout" method="post">
			<%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /> --%>
			<span class="user-info">
                		아이디: ${currentUserId} 권한: ${currentUserAuthority}
			</span>
			
			<button class= "btn btn-secondary"type="submit">로그아웃</button>
		</form>
		<div class="notif-wrapper">
            <div id="notif-bell" class="notif-bell-container">
                <i class="bi bi-bell-fill" style="font-size: 1.5rem; cursor: pointer;"></i>
                <span id="notif-badge" class="notif-badge" style="display: none;"></span>
            </div>

            <div id="notif-dropdown" class="notif-dropdown" style="display: none;">
                <div class="notif-header">최근 알림</div>
                <div id="notif-list-container" class="notif-list">
                    <div class="notif-empty">새로운 알림이 없습니다.</div>
                </div>
                <a href="/api/notifications/all" class="notif-footer">전체 보기</a>
            </div>
        </div>
	</header>

	<div id="notification-container"></div>
