<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<script>
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
</script>