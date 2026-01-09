<%@ tag language="java" pageEncoding="UTF-8"%>
<%@ attribute name="title" required="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>${title}</title>
        <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
        
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