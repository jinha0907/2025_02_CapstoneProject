import argparse
import sys
import os
from dotenv import load_dotenv

try:
    from Model.RAG import main_rag2
    from Model.LLM import main_base_llm
    from db_manager import force_rebuild_db
    from eval import main_eval
except ImportError as e:
    print(f"오류: 필요한 모듈을 임포트할 수 없습니다: {e}")
    sys.exit(1)

def main():
    load_dotenv()
    if not os.getenv("OPENAI_API_KEY"):
        print("경고: .env 파일에서 OPENAI_API_KEY를 찾을 수 없습니다.")

    parser = argparse.ArgumentParser(
        description="K-Culture 퀴즈 RAG 평가 시스템 CLI",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    subparsers = parser.add_subparsers(
        dest="command", 
        required=True,
        help="실행할 작업을 선택하세요."
    )

    parser_rag = subparsers.add_parser(
        "rag", 
        help="RAG 모델 (정답 해설/힌트 분리)을 사용하여 퀴즈 해설을 생성합니다."
    )
    parser_rag.add_argument('--type', type=str, default='Markdown', choices=['PDF', 'Markdown'],help="사용할 지식 베이스 소스 타입을 선택합니다. (기본값: Markdown)")
    parser_rag.add_argument('--embedding_size', type=int, default=3072, help="임베딩 벡터 차원 크기 (기본값: 3072)")
    parser_rag.add_argument('--chunk_size', type=int, default=1000, help="문서 분할 크기 (기본값: 1000)")
    parser_rag.add_argument('--chunk_overlap', type=int, default=50, help="문서 분할 중첩 크기 (기본값: 50)")

    parser_base = subparsers.add_parser(
        "base", 
        help="Base LLM (일반 지식)을 사용하여 퀴즈 해설을 생성합니다."
    )

    parser_build = subparsers.add_parser(
        "build_db", 
        help="설정된 파라미터로 벡터 DB를 강제로 새로 생성합니다."
    )
    
    parser_build.add_argument('--type', type=str, default='Markdown', choices=['PDF', 'Markdown'],help="재생성할 지식 베이스 소스 타입 (기본값: Markdown)")
    parser_build.add_argument('--embedding_size', type=int, default=3072, help="임베딩 벡터 차원 크기 (기본값: 3072)")
    parser_build.add_argument('--chunk_size', type=int, default=1000, help="문서 분할 크기 (기본값: 1000)")
    parser_build.add_argument('--chunk_overlap', type=int, default=50, help="문서 분할 중첩 크기 (기본값: 50)")

    parser_eval = subparsers.add_parser(
        "eval", 
        help="RAG 결과(JSON)를 RAGAs로 평가합니다."
    )
    parser_eval.add_argument('--type', type=str, default='Markdown', choices=['PDF', 'Markdown'], help="소스 타입")
    parser_eval.add_argument('--embedding_size', type=int, default=3072, help="임베딩 차원")
    parser_eval.add_argument('--chunk_size', type=int, default=1000, help="문서 분할 크기")
    parser_eval.add_argument('--chunk_overlap', type=int, default=50, help="문서 분할 중첩 크기")

    args = parser.parse_args()

    if args.command == 'rag':
        print(f"--- RAG ({args.type}) 기반 해설/힌트 생성을 시작합니다 ---")
        print(f"    [설정] C:{args.chunk_size}, O:{args.chunk_overlap}, E:{args.embedding_size}")
        
        main_rag2(args.type, args.embedding_size, args.chunk_size, args.chunk_overlap) 
        
        print(f"--- RAG ({args.type}) 기반 해설/힌트 생성 완료 ---")

    elif args.command == "base":
        print("--- Base LLM 기반 해설 생성을 시작합니다 ---")
        main_base_llm()
        print("--- Base LLM 기반 해설 생성 완료 ---")
        
    elif args.command == "build_db":
        print(f"--- 벡터 DB ({args.type}) 강제 재생성을 시작합니다 ---")
        print(f"    [설정] Chunk Size: {args.chunk_size}, Overlap: {args.chunk_overlap}, Embedding: {args.embedding_size}")
        
        force_rebuild_db(
            args.type, 
            args.embedding_size, 
            args.chunk_size, 
            args.chunk_overlap
        )
        print(f"--- 벡터 DB ({args.type}) 강제 재생성 완료 ---")

    elif args.command == "eval":
        print(f"--- RAGAs 평가 시작 ({args.type}) ---")
        print(f"    [설정] C:{args.chunk_size}, O:{args.chunk_overlap}, E:{args.embedding_size}")
        
        # [수정] 파라미터 전달
        main_eval(
            args.type, 
            args.chunk_size, 
            args.chunk_overlap, 
            args.embedding_size
        )
        print("--- RAGAs 평가 완료 ---")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()