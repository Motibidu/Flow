# Flow - 전자결재 시스템
효율적인 업무 승인 프로세스를 위한 웹 기반 전자결재 플랫폼

## 🛠 Tech Stack

**Backend**: Spring Boot, Spring Security, MyBatis, MySQL  
**Frontend**: JSP  
**etc**: Server-Sent-Events

## ✨ Main Features

### 📝 전자결재
- 결재 문서 작성 및 결재 라인 설정
- 순차적 승인/반려 처리
![bandicam 2026-02-14 15-51-46-136](https://github.com/user-attachments/assets/13711c48-19dd-4ec2-99c9-92ee81a680e7)
![bandicam 2026-02-14 15-52-21-791](https://github.com/user-attachments/assets/19260bd9-87b4-4ddc-9576-5977fb7ea6af)
### 🔒 권한 제어
- @PreAuthorize 기반 메서드 레벨 보안
- 결재 순서 검증 (현재 결재자만 승인 가능)
- 기안자/결재자/대리인별 세밀한 권한 제어
```java
public boolean isCurrentApprover(Integer docId, String username) {
    ElecApprovalHistoryRespDto currentPendingApproval = elecApprovalHistoryMapper
            .getCurrentApprovalHistory(docId)
            .orElseThrow(() -> new UnauthorizedException(HttpStatus.BAD_REQUEST, "결재 순서가 아니거나 결재 권한이 없습니다."));
    return currentPendingApproval.getApproverId().equals(username);
}
```
```java
@PreAuthorize("@documentChecker.isCurrentApprover(#p0, principal.username)")
@PostMapping("/approve/{docId}")
public ResponseEntity<ApiResponse<Void>> approveDocument(
        @PathVariable("docId") int docId,
        @RequestBody ApprovalCommentDto approvalCommentDto,
        @AuthenticationPrincipal UserDetails userDetails) {

    elecApprovalCommandService.approveDocument(docId, approvalCommentDto.comment());

    return ResponseEntity.ok(ApiResponse.success("결재가 승인되었습니다."));
}
```
<img width="1394" height="441" alt="스크린샷 2026-01-27 193336" src="https://github.com/user-attachments/assets/1e219497-8a42-4bab-a890-b3725135f615" />

### ⚡ 안정성
- Spring Event 기반 트랜잭션 분리 (비동기 알림 처리)
- 알림 실패 시에도 결재는 정상 완료
<img width="1378" height="388" alt="스크린샷 2026-01-27 172635" src="https://github.com/user-attachments/assets/fce42c73-e0d9-45b3-926c-ca155dd74d7d" />
<img width="1391" height="159" alt="스크린샷 2026-03-04 232806" src="https://github.com/user-attachments/assets/025d090f-792f-45cb-a50e-db72dd9d2c18" />

# 기타 페이지
### **대시보드 및 실시간 현황**
<img width="1646" height="1279" alt="스크린샷 2026-01-27 170550" src="https://github.com/user-attachments/assets/91ed4f29-605a-4066-aa2e-0606022b7661" />

### **대리결재자 설정**
![bandicam 2026-02-14 17-24-32-774](https://github.com/user-attachments/assets/91dc63f7-d08b-4b3a-99c0-b73935ab270f)




