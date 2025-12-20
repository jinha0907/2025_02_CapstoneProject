# 🇰🇷 HanQ AI
> 한국의 생활·문화 정보를 학습할 수 있는 RAG 기반 외국인을 위한 한국 정착 지원 서비스 **HanQ**의 AI 서비스입니다.  
> 본 프로젝트는 파이썬 기반의 RAG 시스템으로, json 파일로 입력된 퀴즈의 해설 생성 및 난이도를 생성합니다.
>
> 본 프로젝트는 중앙대학교 소프트웨어학부 2025_02 캡스톤 프로젝트 수업 산출물입니다.

# System Architecture

RAG Module: 사회통합프로그램(KIIP) 교재와 고용허가제(EPS-TOPIK) 교재를 검색하여 팩트 기반의 퀴즈, 해설, 힌트를 생성합니다.

Difficulty Module: 유학생 User Study 데이터를 기반으로 체감 난이도를 생성하고 Few-shot으로 학습하여, 새로운 퀴즈의 난이도를 1.0~5.0 척도로 예측합니다.

# Getting Started
이 프로젝트는 main.py CLI 도구를 통해 전체 파이프라인(DB 구축, 생성, 평가)을 실행할 수 있습니다.

```
# 기본 설정으로 빌드 (Markdown 소스 사용)
python main.py build_db --type Markdown

# 옵션 변경 예시 (청크 크기 조절)
python main.py build_db --type Markdown --chunk_size 500 --chunk_overlap 50
```

퀴즈 및 해설 생성 (Run RAG)
구축된 DB를 바탕으로 퀴즈, 정답, 상세 해설 및 유도 힌트를 생성합니다.

```
# RAG 파이프라인 실행
python main.py rag --type Markdown
```

성능 평가 (Evaluation)
생성된 결과물을 RAGAs 프레임워크를 통해 정량적으로 평가합니다.

```
# 평가 실행
python main.py eval
```
