<%@ tag language="java" pageEncoding="UTF-8"%>
<%@ attribute name="title" required="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>${title}</title>
        <!-- Bootstrap 5 CSS & Icons -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
        
        <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
        <!-- Bootstrap 5 JS Bundle -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
        
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/layout.css">
        
    </head>
    <body>
        <div class="header-wrapper">
            <jsp:include page="/WEB-INF/views/common/header.jsp"/>
        </div>

        <div class="main-wrapper">
            <div class="nav-wrapper">
                <jsp:include page="/WEB-INF/views/common/leftNav.jsp"/>
            </div>
        <div class="content-wrapper">
            <jsp:doBody/>
        </div>
        </div>

    </body>
</html>