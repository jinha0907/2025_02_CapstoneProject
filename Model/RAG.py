import os, json, time
from pathlib import Path
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_core.runnables import RunnableParallel
from operator import itemgetter
from util import format_docs, getJsonPath, save_results, read_context, make_contextList
from db_manager import get_vectorstore

def generate_answer_hint(json_file_paths: list[Path], rag_chain, output_filename: str) -> dict:
    all_explanations = {}

    for json_file_path in json_file_paths:
        filename_key = json_file_path.name
        if filename_key == output_filename:
            continue
            
        print(f"\n[--- JSON 파일 처리 시작: {filename_key} ---]")
        if filename_key not in all_explanations:
            all_explanations[filename_key] = []
        
        try:
            with open(json_file_path, 'r', encoding='utf-8') as f:
                quizzes = json.load(f)
            
            processed_quizzes_for_this_file = []
            
            for i, quiz in enumerate(quizzes):
                quiz_id = quiz.get('id', f'quiz_{i}')
                question = quiz['question']
                correct_answer = quiz['answer']
                
                input_data = {
                    "question": question,
                    "answer": correct_answer
                }
                
                try:
                    result = rag_chain.invoke(input_data)
                    parsed_output = result['output'] 
                    explanation_text = parsed_output.get('explanation', "해설 생성 실패")
                    hint_text = parsed_output.get('hint', "힌트 생성 실패")
                    context_list = result['context']
                    
                    quiz['explanation'] = explanation_text 
                    quiz['hint'] = hint_text
                    quiz['contexts'] = context_list
                    
                except Exception as e:
                    print(f"  [Error] 퀴즈 ID {quiz_id} 처리 중 오류: {e}")
                    quiz['explanation'] = "해설을 생성할 수 없습니다."
                    quiz['hint'] = "힌트를 생성할 수 없습니다."
                    quiz['contexts'] = []

                if 'paragraph' in quiz:
                    quiz.pop('paragraph')

                processed_quizzes_for_this_file.append(quiz)
                time.sleep(1)
                print(f"Processed Quiz ID: {quiz_id}")

            all_explanations[filename_key] = processed_quizzes_for_this_file
            
        except json.JSONDecodeError:
            print(f"  오류: {json_file_path.name} 파일 파싱 실패")
        except Exception as e:
            print(f"  오류: {json_file_path.name} 처리 중 문제 발생: {e}")

    print("\n[--- 모든 JSON 파일 처리 완료 ---]")
    return all_explanations

def main_rag2(fileType: str, embedding_size: int, chunk_size: int, chunk_overlap: int):
    print(f"DB 매니저를 통해 벡터 DB를 준비합니다... (Size:{chunk_size}, Overlap:{chunk_overlap}, Dim:{embedding_size})")

    embeddings = OpenAIEmbeddings(model="text-embedding-3-large", dimensions=embedding_size)
    vectorstore = get_vectorstore(embeddings, fileType, chunk_size, chunk_overlap, embedding_size)

    if not vectorstore:
        print("벡터 스토어 준비에 실패했습니다. 스크립트를 종료합니다.")
        return

    retriever = vectorstore.as_retriever(
        search_type="similarity", 
        search_kwargs={
            "k": 5,
            "fetch_k": 20
        }
    )

    print("검색기 생성 완료.")

    RAG_TEMPLATE_FILE = r"template\template_RAG.txt"
    template = read_context(RAG_TEMPLATE_FILE)

    if not template:
        print(f"'{RAG_TEMPLATE_FILE}' 로드 실패. 스크립트를 종료합니다.")
        return

    prompt = PromptTemplate.from_template(template)

    llm = ChatOpenAI(model_name="gpt-4o", temperature=0)

    assign_context = RunnableParallel(
        context=(lambda x: x['question']) | retriever, 
        question=itemgetter("question"),
        answer=itemgetter("answer"),
    )

    rag_chain = assign_context | {
        "output": (lambda x: {
            "context": format_docs(x["context"]), 
            "question": x["question"], 
            "answer": x["answer"]
        }) | prompt | llm | JsonOutputParser(),
        
        "context": (lambda x: make_contextList(x["context"]))
    }
    
    if fileType == 'PDF':
        output_filename = os.path.join('Result', 'RAG', 'PDF', f'PDFRAG_answerAndHint_CS{chunk_size}_CO{chunk_overlap}_ES{embedding_size}.json')
    elif fileType == 'Markdown':
        output_filename = os.path.join('Result', 'RAG', 'Markdown', f'MarkdownRAG_answerAndHint_CS{chunk_size}_CO{chunk_overlap}_ES{embedding_size}.json')
    else:
        print('사전에 정의하지 않은 파일명입니다.')
        return None

    json_file_paths = getJsonPath()
    
    all_explanations = generate_answer_hint(
        json_file_paths,
        rag_chain,
        output_filename
    )

    save_results(all_explanations, output_filename)

if __name__ == "__main__":
    print("이 스크립트는 직접 실행할 수 없습니다.")
    print("`python main.py rag2` 명령어를 사용하세요.")