# Flow - 전자결재 시스템
효율적인 업무 승인 프로세스를 위한 웹 기반 전자결재 플랫폼

## 🛠 Tech Stack

**Backend**: Spring Boot, Spring Security, MyBatis, MySQL  
**Frontend**: JSP 
**etc**: Server-Sent-Events

### 📝 전자결재
- 결재 문서 작성 및 결재 라인 설정
- 순차적 승인/반려 처리
- 실시간 알림 (SSE)
- 대리 결재 기능

### 🔒 권한 제어
- @PreAuthorize 기반 메서드 레벨 보안
- 결재 순서 검증 (현재 결재자만 승인 가능)
- 기안자/결재자/대리인별 세밀한 권한 제어

### ⚡ 성능 & 안정성
- Spring Event 기반 트랜잭션 분리 (비동기 알림 처리)
- 낙관적 락으로 동시성 제어
- 알림 실패 시에도 결재는 정상 완료

## **1. 대시보드 및 실시간 현황**
<img width="1646" height="1279" alt="스크린샷 2026-01-27 170550" src="https://github.com/user-attachments/assets/91ed4f29-605a-4066-aa2e-0606022b7661" />

## **2. 문서 작성 및 결재선**
### **2-1. 문서양식 선택**
![bandicam 2026-02-14 15-50-47-920](https://github.com/user-attachments/assets/b8d14487-e4d7-475d-93f7-3d54d16f852d)

### **2-2. 문서 작성**
![bandicam 2026-02-14 15-51-46-136](https://github.com/user-attachments/assets/13711c48-19dd-4ec2-99c9-92ee81a680e7)

### **2-3. 결재 참여자 선택**
![bandicam 2026-02-14 15-52-21-791](https://github.com/user-attachments/assets/19260bd9-87b4-4ddc-9576-5977fb7ea6af)

### **2-4. 저장한 결재선 불러오기**
![bandicam 2026-02-14 15-53-43-701](https://github.com/user-attachments/assets/21868241-fdae-4b86-bd30-355a875e78b6)

### **3. 문서 상세 페이지**
![bandicam 2026-02-14 15-54-54-281](https://github.com/user-attachments/assets/d93ec0fa-b988-4a6d-aaa7-e28da96fa1ae)



## **4. 결재 문서 리스트(임시저장부터 완료까지 양식 동일함)**
![bandicam 2026-02-14 15-54-29-610](https://github.com/user-attachments/assets/15705bdd-96ab-4b05-8d31-6ed51243b920)


### **5. "김사원" 검색결과**
![bandicam 2026-02-14 15-55-32-267](https://github.com/user-attachments/assets/d00a4496-9003-4828-8dba-3cc618ed0f7c)




### **6. 결재자 시점 상세 페이지(승인 및 반려)**
![bandicam 2026-02-14 15-57-02-117](https://github.com/user-attachments/assets/f1a9d2bc-a89f-4109-9023-d46c3f737703)

### **7. 대리결재자 설정**
![bandicam 2026-02-14 17-24-32-774](https://github.com/user-attachments/assets/91dc63f7-d08b-4b3a-99c0-b73935ab270f)


### **8. 최근 알림 수신 목록**
<img width="1378" height="388" alt="스크린샷 2026-01-27 172635" src="https://github.com/user-attachments/assets/fce42c73-e0d9-45b3-926c-ca155dd74d7d" />




### **9. 상태 유효성 검증 실패 페이지**
<img width="1394" height="441" alt="스크린샷 2026-01-27 193336" src="https://github.com/user-attachments/assets/1e219497-8a42-4bab-a890-b3725135f615" />



