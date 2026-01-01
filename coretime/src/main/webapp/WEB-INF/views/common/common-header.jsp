<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script> --%>

<%-- <script>
    console.log("Common Header Loaded");     
    
    document.addEventListener("DOMContentLoaded", function() {
        const userId = "${currentUserId}";
        
        if (userId && userId !== "") {
            const socket = new SockJS('/ws-stomp');
            const stompClient = Stomp.over(socket);

            stompClient.connect({}, function (frame) {
                console.log('Connected as: ' + userId);
                
                // Spring Security가 인증된 상태라면 아래 경로로 구독
                stompClient.subscribe('/user/queue/notifications', function (notification) {
                    alert("🔔 알림: " + notification.body);
                });
            }, function(error) {
                console.error('STOMP error:', error);
            });
        }
    });
</script> --%>

<script>
    console.log("SSE Notification System Loaded");
    
    document.addEventListener("DOMContentLoaded", function() {
        const userId = "${currentUserId}";
        
        if (userId && userId !== "") {
            // 1. SSE 연결 생성
            const eventSource = new EventSource('/api/notifications/subscribe?userId=' + userId);

            // 2. 서버에서 보낸 'notification' 이벤트 수신
            eventSource.addEventListener("notification", function(event) {
                console.log("알림 수신:", event.data);
                alert("🔔 알림: " + event.data);
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