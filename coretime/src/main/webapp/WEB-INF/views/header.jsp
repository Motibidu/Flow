<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<script>
	console.log("SSE Notification System Loaded");
    
	document.addEventListener("DOMContentLoaded", function() {
		const userId = "${currentUserId}";
		
		if (userId && userId !== "") {
		// 1. SSE 연결 생성
		const eventSource = new EventSource('/api/notifications/subscribe?userId=' + userId);

		// 2. 서버에서 보낸 'notification' 이벤트 수신
		eventSource.addEventListener("notification", function(event) {
			console.log("알림 수신:", event);
			
			try {
				// 서버에서 Map(JSON)으로 보냈으므로 파싱 가능
				const data = JSON.parse(event.data);
				showToast(data.message, data.targetUrl);
			} catch (e) {
				// 만약 서버에서 순수 문자열을 보냈을 경우를 대비한 예외 처리
				console.warn("JSON 파싱 실패, 일반 문자열로 처리합니다.");
				showToast(event.data, "#");
			}
		});

		// 연결 유지 확인용 (선택)
		eventSource.addEventListener("connect", function(event) {
			console.log("SSE 연결 성공");
		});

		// 에러 처리
		eventSource.onerror = function(error) {
			console.error("SSE 연결 에러:", error);
			// 브라우저가 자동으로 재연결을 시도합니다.
		};
		}
	});
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
</style>
</head>
<body>
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
	</header>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">

	<div id="notification-container"></div>

	<script>
		function showToast(message, targetUrl) {
			// 2. ID를 맞춰서 가져옵니다.
			let container = document.getElementById('notification-container');
			
			
			// 알림 요소 생성
			const toast = document.createElement('div');
			toast.className = 'notif-toast';
			
			toast.innerHTML = '<div class="notif-message">' + message + '</div>';

			// 클릭 시 해당 URL로 이동
			toast.onclick = function() {
			if (targetUrl && targetUrl !== "#") {
				window.location.href = targetUrl;
			}
			};

			// 컨테이너에 추가 (이제 에러가 나지 않습니다)
			container.appendChild(toast);

			// 5초 뒤에 자동으로 사라짐
			setTimeout(() => {
				toast.style.opacity = '0';
				toast.style.transform = 'translateX(100%)';
				setTimeout(() => toast.remove(), 10000);
			}, 10000);
		}
	</script>
</body>
</html>