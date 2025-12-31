<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <%-- <meta name="_csrf_token" content="${_csrf.token}" />
            <meta name="_csrf_header" content="${_csrf.headerName}" /> --%>
            <title>사용자 목록</title>

            <link href="https://cdn.datatables.net/2.0.8/css/dataTables.dataTables.min.css" rel="stylesheet">

            <style>
                #nav {
                    display: inline;
                    width: 200px;
                    padding: 10px;
                    box-sizing: border-box;
                }

                .content{
                    display: flex;
                }

                .main-content {
                    flex-grow: 1;
                    padding: 20px;
                    box-sizing: border-box;
                }

                h1 {
                    color: #333;
                }

                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin-top: 20px;
                }

                th {
                    background-color: #f2f2f2;
                }
            </style>
        </head>

        <body>
            <div id="header">
                <%@ include file="header.jsp" %>
            </div>
            <div class= "content">
                <div id="nav">
                    <%@ include file="leftNav.jsp" %>
                </div>

                <div class="main-content">
                    <h2>사용자 목록 (${userList.size()}명)</h2>

                    <c:if test="${empty userList}">
                        <p>등록된 사용자가 없습니다.</p>
                    </c:if>
                    <c:if test="${not empty userList}">
                        <c:if test="${currentUserAuthority eq 'ROLE_ADMIN'}">
                            <div>
                                <button class="btn btn-outline-secondary" onclick="location.href='/users/new'">신규 유저 생성</button>
                                <button class="btn btn-outline-secondary" id="deleteSelectedUsersBtn">유저 삭제</button>
                            </div>
                        </c:if>

                        <table id="userTable" style="width:100%">
                            <thead>
                                <tr>
                                    <th><input type="checkbox" id="selectAllUsers"></th>
                                    <th>이름</th>
                                    <th>아이디</th>
                                    <th>이메일</th>
                                    <th>전화번호</th>
                                    <th>직위</th>
                                    <th>부서</th>
                                    <th>수정일</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="user" items="${userList}">
                                    <tr>
                                        <td><input type="checkbox" name="selectedUsers" value="${user.id}"></td>
                                        <td><c:if test="${currentUserAuthority eq 'ROLE_ADMIN'}">
                                                <a href="/users/edit?existingId=${user.id}">${user.name}</a>
                                            </c:if>
                                            <c:if test="${currentUserAuthority ne 'ROLE_ADMIN'}">
                                                ${user.name}
                                            </c:if></td>
                                        <td>${user.id}</td>
                                        <td>${user.email}</td>
                                        <td>${user.tel}</td>
                                        <td>${user.rank}</td>
                                        <td>${user.department}</td>
                                        <td>${user.updatedAt}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:if>
                </div>
            </div>

            <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
            <script src="https://cdn.datatables.net/2.0.8/js/dataTables.min.js"></script>

            <script>
                $(document).ready(function () {
                    // DataTables 초기화
                    $('#userTable').DataTable({
                        // DataTables 옵션:
                        // 'ordering': true, // 정렬 기능 활성화 (기본값 true)
                        // 'searching': true, // 검색 기능 활성화 (기본값 true)
                        // 'paging': true, // 페이지네이션 기능 활성화 (기본값 true)
                        // 'lengthMenu': [[10, 25, 50, -1], [10, 25, 50, "All"]], // 보여줄 행 수 옵션
                        // 'pageLength': 10, // 기본 페이지당 행 수
                        'language': { // 한글화
                            'decimal': '',
                            'emptyTable': '데이터가 없습니다.',
                            'info': '총 _TOTAL_명 중 _START_에서 _END_까지 표시',
                            'infoEmpty': '0명 중 0에서 0까지 표시',
                            'infoFiltered': '(총 _MAX_명에서 필터링됨)',
                            'infoPostFix': '',
                            'thousands': ',',
                            'lengthMenu': '_MENU_개씩 보기',
                            'loadingRecords': '로딩 중...',
                            'processing': '처리 중...',
                            'search': '검색:',
                            'zeroRecords': '일치하는 데이터가 없습니다.',
                            'paginate': {
                                'first': '처음',
                                'last': '마지막',
                                'next': '다음',
                                'previous': '이전'
                            },
                            'aria': {
                                'sortAscending': ': 오름차순으로 정렬',
                                'sortDescending': ': 내림차순으로 정렬'
                            }
                        },
                        // 정렬을 하지 않을 컬럼 지정 (체크박스 컬럼)
                        "columnDefs": [
                            { "orderable": false, "targets": 0 } // 첫 번째 컬럼 (인덱스 0)은 정렬 비활성화
                        ]
                    });
                });

                // 기존의 체크박스 전체 선택/해제 로직은 그대로 유지
                document.getElementById('selectAllUsers').addEventListener('change', function () {
                    const checkboxes = document.querySelectorAll('input[name="selectedUsers"]');
                    checkboxes.forEach(checkbox => {
                        checkbox.checked = this.checked;
                    });
                });

                // 삭제 버튼 로직은 그대로 유지
                document.getElementById('deleteSelectedUsersBtn').addEventListener('click', function () {
                    const selectedIds = [];
                    const checkboxes = document.querySelectorAll('input[name="selectedUsers"]');
                    checkboxes.forEach(checkbox => {
                        if (checkbox.checked) {
                            selectedIds.push(checkbox.value);
                        }
                    })
                    const confirmDelete = confirm('선택된 유저를 정말 삭제하시겠습니까?');

                    if (confirmDelete) {
                        fetch('/users/delete', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({ ids: selectedIds })
                        })
                        .then(response => {
                            if (response.ok) {
                                alert('선택된 유저가 성공적으로 삭제되었습니다.');
                                location.reload();
                            } else {
                                return response.json().then(errorData => {
                                    alert('유저 삭제 중 오류가 발생했습니다: ' + (errorData.message || '알 수 없는 오류'));
                                }).catch(() => {
                                    alert('유저 삭제 중 오류가 발생했습니다. 서버 응답을 확인하세요.');
                                });
                            }
                        })
                        .catch(error => {
                            console.error('삭제 요청 중 오류:', error);
                            alert('서버와 통신 중 오류가 발생했습니다.');
                        });
                    }
                });
            </script>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
        </body>

        </html>`