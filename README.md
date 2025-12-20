# 🇰🇷 HanQ AI
> 한국의 생활·문화 정보를 학습할 수 있는 RAG 기반 외국인을 위한 한국 정착 지원 서비스 **HanQ**의 AI 서비스입니다.  
> 본 프로젝트는 파이썬 기반의 RAG 시스템으로, json 파일로 입력된 퀴즈의 해설 생성 및 난이도를 생성합니다.
>
> 본 프로젝트는 중앙대학교 소프트웨어학부 2025_02 캡스톤 프로젝트 수업 산출물입니다.

## System Architecture

- **RAG Module**
  - 사회통합프로그램(KIIP) 교재와 고용허가제(EPS-TOPIK) 교재를 검색하여 팩트 기반의 퀴즈, 해설, 힌트를 생성합니다.

- **Difficulty Module**
  -  유학생 User Study 데이터를 기반으로 체감 난이도를 생성하고 Few-shot으로 학습하여, 새로운 퀴즈의 난이도를 1.0~5.0 척도로 예측합니다.

## Getting Started

**1. 벡터 DB 구축 (Build Vector DB)**

지식 베이스(Markdown/PDF)를 임베딩하여 FAISS DB를 생성합니다.
```
# 기본 설정으로 빌드 (Markdown 소스 사용)
python main.py build_db --type Markdown

# 옵션 변경 예시 (청크 크기 조절)
python main.py build_db --type Markdown --chunk_size 500 --chunk_overlap 50
```

**2. 퀴즈 및 해설 생성 (Run RAG)**

구축된 DB를 바탕으로 각 퀴즈에 대한 해설 및 힌트를 생성합니다.

```
# RAG 파이프라인 실행
python main.py rag --type Markdown
```

**3. 성능 평가 (Evaluation)**

생성된 결과물을 RAGAs 프레임워크를 통해 정량적으로 평가합니다.

```
# 평가 실행
python main.py eval
```
## Dependencies

```
python 3.12.3

# Core & Data Utilities
pandas
numpy
python-dotenv

# LLM & OpenAI
openai

# LangChain Ecosystem
langchain
langchain-core
langchain-community
langchain-openai
langchain-text-splitters

# Vector Database
faiss-cpu

# Document Loaders (for PDF)
pypdf

# Evaluation (RAGAs)
ragas
datasets

# Visualization
matplotlib
seaborn
mplcursors
```
