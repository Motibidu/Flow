<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout title="접근 거부">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 text-center">
                <h2 class="mb-4">접근이 거부되었습니다.</h2>
                <p class="lead">
                    요청하신 페이지에 접근할 권한이 없습니다.
                </p>
                <c:if test="${not empty errorMessage}">
                    <p class="text-danger mt-3">
                        <strong>사유:</strong> ${errorMessage}
                    </p>
                </c:if>
                <hr>
                <p>
                    문제가 있다고 생각하시면 관리자에게 문의해주세요.
                </p>
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">홈으로 돌아가기</a>
            </div>
        </div>
    </div>
</t:layout>
