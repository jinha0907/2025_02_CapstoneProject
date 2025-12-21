# HanQ — 국내 체류외국인을 위한 한국 정착 지원 플랫폼

- HanQ는 국내 체류외국인이 한국 사회에 안정적으로 적응하고 자립할 수 있도록, **일상생활 정보**와 **한국 사회 전반(법·사회·문화 등) 정보**를 학습할 수 있는 모바일 기반 교육 플랫폼입니다.  
- 줄글(정보 열람) + 퀴즈(반복 학습) 형태로 제공하며, 퀴즈 학습 과정에서 **RAG 기반 해설/힌트 생성**과 **사용자 체감 난이도 반영**을 통해 학습 지속성과 정보 신뢰성을 강화했습니다.

<img src="HanQ_mascot.png" width="200" height="400"/>

## Problem Statement

- 생산가능인구 감소와 국내 체류외국인 증가라는 사회적 흐름 속에서,
- 체류외국인이 겪는 언어/문화/제도 이해의 장벽을 완화하고,
- 정착 초기의 불확실성을 줄일 수 있는 **직·간접적 정보 전달 및 학습 서비스**가 필요하다는 문제의식에서 출발했습니다.

## What HanQ Provides

- **학습 콘텐츠**
  - 일상생활에 직접 필요한 정보 (e.g., 병원 이용, 생활 절차)
  - 한국 사회 전반 정보 (e.g., 법/제도, 사회, 전통문화)

- **학습 방식**
  - 줄글 기반 정보 열람(빠른 접근, 즉시 학습)
  - 퀴즈 기반 반복 학습(흥미 유도, 학습 고착)

- **AI 기반 품질 개선**
  - RAG 기반 해설/힌트 생성으로 hallucination 리스크 완화
  - 사용자 학습 지속을 위한 난이도 설계(도메인 심리 장벽 반영)

- **학습 동기 부여**
  - 학습 결과 저장 및 통계(학습 현황)
  - 경험치/티어 시스템을 통한 지속 사용 유도

## System Overview

HanQ는 다음과 같은 흐름으로 동작합니다.
![System Architecture](System%20Architecture.png)
1. **AI Layer (Offline Processing)**
   - 공인/교재 기반 지식 DB 구성(EPS-TOPIK, KIIP 등)
   - VectorDB 구축 및 RAG 파이프라인으로 퀴즈 해설/힌트 생성
   - User study 기반 난이도 산출(IRT + PADI) 및 LLM few-shot으로 확장 난이도 생성

2. **Server Layer**
   - 사용자/학습/퀴즈 데이터 저장 및 서비스 API 제공(REST)
   - 학습 세션/통계/티어 반영 로직 처리

3. **Mobile App (Client)**
   - 회원가입/로그인
   - 퀴즈 학습 및 결과 확인
   - 학습 현황(통계) 조회
   - 정보 모음(줄글) 열람

## Repository Organization

이 레포는 파트별 개발을 **브랜치 단위**로 분리하여 관리합니다.

- `FE` branch: Mobile App(Client)
- `BE` branch: Server(API) + DB 연동
- `AI` branch: Knowledge DB / VectorDB / RAG / Difficulty pipeline

각 브랜치에는 **개별 README**가 포함되어 있으며, 실행 방법/환경 설정/구성 상세는 해당 문서를 기준으로 합니다.
