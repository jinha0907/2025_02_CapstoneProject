# 🇰🇷 HanQ Backend  
> 한국의 생활·문화 정보를 학습할 수 있는 RAG 기반 외국인을 위한 한국 정착 지원 서비스 **HanQ**의 백엔드 저장소입니다.  
> 본 프로젝트는 Spring Boot 기반 REST API 서버로, 사용자 맞춤형 퀴즈 제공 및 학습 통계 관리 기능을 제공합니다.
>
> 본 프로젝트는 중앙대학교 소프트웨어학부 2025_02 캡스톤 프로젝트 수업 산출물입니다.

---

## 📘 프로젝트 개요  

HanQ는 한국 사회에 적응하고자 하는 외국인을 위한 **한국문화 학습 서비스**입니다.  
생활 정보, 문화 퀴즈, 학습 현황 분석을 하나의 어플리케이션으로 제공하며,  
사용자는 학습량과 난이도를 설정하고 해당 퀴즈를 풀고 자신의 학습 통계를 확인할 수 있습니다.
또한 다양한 생활정보, 문화 및 사회정보를 담고 있습니다.

---

## 🧱 아키텍처 개요  

HanQ의 백엔드는 Spring Boot 기반의 **계층형 아키텍처 (Layered Architecture)** 로 설계되었습니다.  
Controller, Service, Repository, Entity, DTO를 명확히 분리하여 유지보수성과 확장성을 높였습니다.

Controller → Service → Repository → Entity → DTO (Request / Response)

---

## ⚙️ 주요 기능  

| 구분 | 기능 설명 |
|------|------------|
| 👤 **회원 관리** | 회원가입 / 로그인 / 사용자 설정 (난이도, 학습량) |
| 🧩 **퀴즈 관리** | 사용자 난이도 기반 퀴즈 제공, 복습 퀴즈 자동 출제 |
| 🧠 **학습 결과 관리** | 사용자의 퀴즈 결과 저장 및 티어 자동 갱신 |
| 📊 **통계 기능** | 일일 학습량, 정답률, 카테고리별 학습 현황 분석 |
| 📚 **생활·문화 정보 제공** | 한국 생활 정보 및 문화 콘텐츠 API 제공 |
| ⚠️ **전역 예외 처리** | 표준화된 에러 응답(`ErrorResponse`) 구조 및 코드 기반 핸들링 |
| 🧰 **데이터 로더** | JSON 기반 퀴즈 자동 적재(`QuizDataLoader`) 기능 |

---

## 🧩 데이터베이스 구조 (ERD 요약)

**핵심 테이블 구성**

| 테이블 | 설명 |
|--------|------|
| `users`, `user_settings`, `user_tier` | 사용자 정보, 설정, 티어 정보 관리 |
| `quiz_header`, `quiz_details` | 카테고리 및 퀴즈 세부 정보 (1:N 관계) |
| `quiz_session`, `learning_stats` | 퀴즈 결과 및 학습 통계 기록 |
| `life_information`, `culture_information` | 생활/문화 정보 제공 콘텐츠 |

> 데이터베이스는 3NF 수준의 정규화를 유지하되,  
> 통계 조회 성능 향상을 위해 `learning_stats`는 비정규화하였습니다.

---

## 🚀 실행 방법  

### 1️⃣ 환경 설정  
# src/main/resources/application.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/hanq?serverTimezone=Asia/Seoul
    username: root
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true

### 2️⃣ 빌드 및 실행
# Build
./gradlew clean build

# Run
java -jar build/libs/hanq-0.0.1-SNAPSHOT.jar

---
## 🧪 API 문서 (Swagger)
HanQ는 SpringDoc OpenAPI를 사용하여 모든 API를 문서화하였습니다.
다음 주소로 접속할 수 있습니다:

🔗 http://localhost:8080/swagger-ui/index.html

모든 API는 ErrorResponse 스키마를 포함한 표준 응답 구조를 따릅니다.

---
## ⚙️ 기술 스택
- **언어**: Java 17
- **Main**: Spring Boot 3.3.1
- **DB**: MySQL 8.0  
- **ORM**: Spring Data JPA / Hibernate  
- **API 문서화**: Swagger (SpringDoc OpenAPI)  
- **보안**: Spring Security, BCrypt
- **배포**: AWS EC2
- **Build Tool**: Gradle

---
## 🧰 개발 환경
- **IDE**:	IntelliJ IDEA Ultimate
- **배포 환경**:	Ubuntu 22.04 (EC2)
- **JDK**:	OpenJDK 17

---
## 👨‍💻 담당 정보
- **BE Developer**	김진하 /	서버 아키텍처 설계, API 구현, 데이터 모델링, 예외 처리, UI디자인

---
## 📜 라이선스
이 프로젝트는 MIT License 하에 배포됩니다.
자세한 내용은 LICENSE 파일을 참고하세요.

---

✨ “Learn Korea, Play Quiz, Grow with HanQ.”
한국 문화를 배우는 가장 즐거운 방법, HanQ.
