<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>전체 알림 - Coretime</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .notif-page-container { max-width: 800px; margin: 50px auto; padding: 20px; }
        .notif-card { border: none; box-shadow: 0 2px 15px rgba(0,0,0,0.08); border-radius: 12px; }
        .list-group-item { padding: 20px; border-left: none; border-right: none; transition: background 0.2s; cursor: pointer; }
        .list-group-item:hover { background-color: #f8f9ff; }
        .list-group-item.unread { background-color: #f0f7ff; border-left: 4px solid #007bff; }
        .notif-time { font-size: 0.8rem; color: #999; }
        .unread-dot { width: 8px; height: 8px; background: #007bff; border-radius: 50%; display: inline-block; margin-right: 10px; }
    </style>
</head>
<body>
    <%@ include file="../header.jsp" %>

    <div class="container notif-page-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3><i class="bi bi-bell"></i> 전체 알림</h3>
            <button class="btn btn-outline-primary btn-sm" onclick="markAllAsRead()">모두 읽음으로 표시</button>
        </div>

        <div class="card notif-card">
            <div id="all-notif-list" class="list-group list-group-flush">
                <div class="text-center p-5">알림을 불러오는 중...</div>
            </div>
        </div>
    </div>

    <script>
        const currentUserId = "${currentUserId}";

        document.addEventListener("DOMContentLoaded", function() {
            loadAllNotifications();
        });

        function loadAllNotifications() {
            fetch('/api/notifications/recent-notifications?userId=' + currentUserId) // 기존 API 재활용 (필요시 전체조회 API로 변경)
                .then(res => res.json())
                .then(data => {
                    const container = document.getElementById('all-notif-list');
                    container.innerHTML = '';

                    if (data.length === 0) {
                        container.innerHTML = '<div class="text-center p-5 text-muted">알림 내역이 없습니다.</div>';
                        return;
                    }

                    data.forEach(item => {
                        const div = document.createElement('div');
                        const isUnread = item.isRead === 'UNREAD';
                        div.innerHTML=`
                            <div class="list-group-item \${isUnread ? 'unread' : ''}">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        \${isUnread ? '<span class="unread-dot"></span>' : ''}
                                        <span>\${item.notifId}.</span>
                                        <span class="fw-medium">\${item.message}</span>
                                    </div>
                                    <span class="notif-time">\${formatDate(item.createdAt)}</span>
                                </div>
                            </div>
                        `;

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
                        container.appendChild(div);
                    });
                });
        }

        function markAllAsRead() {
            if(!confirm("모든 알림을 읽음 처리하시겠습니까?")) return;

            fetch('/api/notifications/mark-all-read?userId=' + currentUserId, { method: 'POST' })
                .then(res => {
                    if(res.ok) {
                        alert("모든 알림이 읽음 처리되었습니다.");
                        loadAllNotifications();
                        // 헤더의 배지도 업데이트
                        const badge = document.getElementById('notif-badge');
                        if (badge) badge.style.display = 'none';
                    }
                });
        }

        function formatDate(dateStr) {
            const date = new Date(dateStr);
            return date.toLocaleString();
        }
    </script>
</body>
</html>