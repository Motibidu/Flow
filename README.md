# 🚀 Flow

## 개요
> 기업 내 결재 업무를 디지털화 시킨 전자결재 시스템입니다. 문서의 임시저장부터 승인/반려 까지의 라이프사이클을 상태 전이 모델로 설계했습니다. 실시간 알림, 동시성 제어, 권한 제어에 중점을 두고 개발했습니다.

## ERD
<img width="800" alt="coretiem erd" src="https://github.com/user-attachments/assets/d6e7b49e-a8b9-44ed-ac8c-28f938c8a548" />




| Table | Description |
| :--- | :--- |
| **my_approval_line** | 사용자가 저장한 결재선입니다.   |
| **substitute_approval** | 대리 결재 리스트입니다. |

## 기술 스택
| Category | Tech Stack |
| :--- | :--- |
| **Backend** | Spring Boot / Spring Security / MyBatis / MySQL |
| **Database** | MySQL |
| **FrontEnd** | JSP | 
| **etc** | Server-Sent-Events |

