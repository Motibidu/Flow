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
    document.addEventListener("DOMContentLoaded", function() {
        // JSP 세션에 저장된 currentUserId를 자바스크립트 변수로 할당
        const userId = "${currentUserId}"; 
        
        if (userId && userId.trim() !== "") {
            console.log("웹소켓 연결 시도 중... (ID: " + userId + ")");
            
            const socket = new SockJS('/ws-stomp');
            const stompClient = Stomp.over(socket);

            // 디버그 로그가 너무 많으면 아래 주석 해제 (콘솔 깨끗해짐)
            // stompClient.debug = null;

            stompClient.connect({}, function (frame) {
                console.log('연결 성공: ' + frame);
                
                // [구독] 내 계정 전용 알림 채널
                // Spring의 convertAndSendToUser를 쓸 때는 경로를 아래와 같이 맞춥니다.
                stompClient.subscribe('/user/queue/notifications', function (notification) {
                    showNotificationBanner(notification.body);
                });
            }, function(error) {
                console.error('웹소켓 연결 실패: ', error);
            });
        }
    });

    function showNotificationBanner(message) {
        // 브라우저 기본 알림창 (추후 Toast UI 등으로 교체 권장)
        alert("🔔 결재 알림\n" + message);
        
        // 여기에 상단 바 알림 아이콘 숫자를 +1 하는 로직을 추가할 수 있습니다.
        // 예: document.getElementById('noti-count').innerText = ++count;
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
</body>
</html>