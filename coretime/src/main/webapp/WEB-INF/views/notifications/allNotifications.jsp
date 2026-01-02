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

        <nav class="mt-4">
            <ul id="pagination-container" class="pagination justify-content-center"></ul>
        </nav>
    </div>

    <script>
        // 서버에서 넘겨주는 유저 ID (JSP EL 사용)
        const currentUserId = "${currentUserId}";

        document.addEventListener("DOMContentLoaded", function() {
            loadAllNotifications(1); // 초기 로딩 시 1페이지 요청
        });

        function loadAllNotifications(page) {
            // API 호출 시 page와 size 파라미터 전달
            fetch('/api/notifications/all-notifications?userId=' + currentUserId + '&page=' + page + '&size=15')
                .then(res => res.json())
                .then(data => {
                    console.log("data: ", data);
                    const container = document.getElementById('all-notif-list');
                    container.innerHTML = '';

                    // data.list는 PageHelper가 반환하는 실제 데이터 리스트입니다.
                    if (!data.list || data.list.length === 0) {
                        container.innerHTML = '<div class="text-center p-5 text-muted">알림 내역이 없습니다.</div>';
                        return;
                    }

                    data.list.forEach(item => {
                        const div = document.createElement('div');
                        const isUnread = item.isRead === 'UNREAD';
                        
                        div.className = 'list-group-item ' + (isUnread ? 'unread' : '');
                        
                        // JSP EL 충돌 방지를 위해 백틱(`) 대신 문자열 더하기 사용 (가장 안전)
                        let html = '<div class="d-flex justify-content-between">' +
                                   '  <div>' +
                                   (isUnread ? '    <span class="unread-dot"></span>' : '') +
                                   '    <span>' + item.notifId + '. </span>' +
                                   '    <span class="fw-medium">' + item.message + '</span>' +
                                   '  </div>' +
                                   '  <span class="notif-time">' + formatDate(item.createdAt) + '</span>' +
                                   '</div>';
                        
                        div.innerHTML = html;
                        div.onclick = function() {
                            handleNotifClick(item);
                        };
                        container.appendChild(div);
                    });

                    // 페이징 버튼 렌더링
                    renderPagination(data);
                })
                .catch(err => {
                    console.error("데이터 로드 실패:", err);
                    document.getElementById('all-notif-list').innerHTML = '<div class="text-center p-5 text-danger">데이터를 불러오는 중 오류가 발생했습니다.</div>';
                });
        }

        // PageHelper 정보를 이용한 페이징 버튼 생성
        function renderPagination(data) {
            const paginationContainer = document.getElementById('pagination-container');
            paginationContainer.innerHTML = '';

            // 이전 페이지 버튼
            if (data.hasPreviousPage) {
                const prevLi = document.createElement('li');
                prevLi.className = 'page-item';
                prevLi.innerHTML = '<a class="page-link" href="#" onclick="loadAllNotifications(' + data.prePage + '); return false;">이전</a>';
                paginationContainer.appendChild(prevLi);
            }

            // 페이지 번호들 (navigatepageNums 배열 사용)
            data.navigatepageNums.forEach(num => {
                const li = document.createElement('li');
                li.className = 'page-item ' + (num === data.pageNum ? 'active' : '');
                li.innerHTML = '<a class="page-link" href="#" onclick="loadAllNotifications(' + num + '); return false;">' + num + '</a>';
                paginationContainer.appendChild(li);
            });

            // 다음 페이지 버튼
            if (data.hasNextPage) {
                const nextLi = document.createElement('li');
                nextLi.className = 'page-item';
                nextLi.innerHTML = '<a class="page-link" href="#" onclick="loadAllNotifications(' + data.nextPage + '); return false;">다음</a>';
                paginationContainer.appendChild(nextLi);
            }
        }

        function handleNotifClick(item) {
            if (item.isRead === 'UNREAD') {
                fetch('/api/notifications/mark-read?notifId=' + item.notifId, { method: 'POST' })
                    .then(res => {
                        if (res.ok && item.targetUrl) location.href = item.targetUrl;
                    });
            } else if (item.targetUrl) {
                location.href = item.targetUrl;
            }
        }

        function formatDate(dateStr) {
            if(!dateStr) return '';
            const date = new Date(dateStr);
            return date.getFullYear() + '.' + (date.getMonth()+1) + '.' + date.getDate() + ' ' + date.getHours() + ':' + date.getMinutes();
        }

        function markAllAsRead() {
            if(!confirm("모든 알림을 읽음 처리하시겠습니까?")) return;
            fetch('/api/notifications/mark-all-read?userId=' + currentUserId, { method: 'POST' })
                .then(res => {
                    if(res.ok) {
                        alert("모든 알림이 읽음 처리되었습니다.");
                        loadAllNotifications(1);
                    }
                });
        }
    </script>
</body>
</html>