import json, re
from pathlib import Path
from langchain_core.documents import Document
import pandas as pd
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import seaborn as sns
import mplcursors   # 🔥 tooltip 기능
import os

plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False
chunk_sizes = [250, 500, 1000]      # 열(Col)
chunk_overlaps = [50, 100]     # 행(Row)
emb_sizes = [512, 1024, 2048, 3072] # X축
file_type = "PDF" 

PDF_FILEPATHS = [
    'Datasets\Database_RAG\PDF\EPS_Notion.pdf',
    'Datasets\Database_RAG\PDF\KIIP_Notion_DB_Advanced.pdf',
    'Datasets\Database_RAG\PDF\KIIP_Notion_DB.pdf'
]

MARKDOWN_FILEPATHS = [
    'Datasets\Database_RAG\Markdown\EPS_Notion.md',
    'Datasets\Database_RAG\Markdown\KIIP_Notion_DB_Advanced.md',
    'Datasets\Database_RAG\Markdown\KIIP_Notion_DB.md'
]

def extract_difficulty(val):
        if pd.isna(val): return None
        match = re.search(r'\((\d)\)', str(val))
        return int(match.group(1)) if match else None

def simplify_prof(val):
    if pd.isna(val): return "Unknown"
    if "Advanced" in val: return "Advanced"
    if "Intermediate" in val: return "Intermediate"
    if "Beginner" in val: return "Beginner"
    return "Unknown"

def extract_domain(quiz_id):
    parts = quiz_id.split("_")
    return parts[1] if len(parts) >= 3 else "unknown"

def make_contextList(docs : list[Document]) -> list:
    return [doc.page_content.replace("\n", "") for doc in docs]

def format_docs(docs: list[Document]) -> str:
    return "\n\n".join(doc.page_content for doc in docs)

def read_context(filepath: str) -> str:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            template_str = f.read()
        return template_str
    except FileNotFoundError:
        print(f"오류: 프롬프트 템플릿 파일을 찾을 수 없습니다. (경로: {filepath})")
        return ""
    except Exception as e:
        print(f"오류: 프롬프트 템플릿 파일 로드 중 문제 발생: {e}")
        return ""

def getJsonPath():
    script_dir = Path(__file__).parent 
    search_dir = script_dir / 'Datasets' / 'Quiz'
    json_file_paths = list(search_dir.rglob('*.json'))

    return json_file_paths

def save_results(data, output_filename: str):
    final_data_to_save = data 
    merged_list = []
    
    for quiz_list in data.values():
        merged_list.extend(quiz_list)
    
    final_data_to_save = merged_list 
    
    try:
        with open(output_filename, 'w', encoding='utf-8') as f:
            json.dump(final_data_to_save, f, ensure_ascii=False, indent=4)
        print(f"\n[저장 완료] 모든 해설이 '{output_filename}' 파일에 성공적으로 저장되었습니다.")
    
    except Exception as e:
        print(f"[저장 실패] 결과 파일 저장 중 오류 발생: {e}")

def extract_RAGAS(file_name):
    df = pd.read_csv(file_name)
    avg_faithfulness = df['faithfulness'].mean()
    avg_answer_relevancy = df['answer_relevancy'].mean()

    return avg_faithfulness, avg_answer_relevancy

def load_all_experiment_data():
    data_map = {}
    
    for emb in emb_sizes:
        expl_faith = np.zeros((len(chunk_overlaps), len(chunk_sizes)))
        expl_rel = np.zeros((len(chunk_overlaps), len(chunk_sizes)))
        hint_faith = np.zeros((len(chunk_overlaps), len(chunk_sizes)))
        hint_rel = np.zeros((len(chunk_overlaps), len(chunk_sizes)))
        
        for r_idx, overlap in enumerate(chunk_overlaps):
            for c_idx, size in enumerate(chunk_sizes):
                config_str = f"CS{size}_CO{overlap}_ES{emb}"
                
                file_expl = os.path.join('Result', 'RAGAS', 'Explanation', f'Eval_Expl_{file_type}_{config_str}.csv')
                file_hint = os.path.join('Result', 'RAGAS', 'Hint', f'Eval_Hint_{file_type}_{config_str}.csv')
                
                ef, er = extract_RAGAS(file_expl)
                hf, hr = extract_RAGAS(file_hint)
                
                expl_faith[r_idx, c_idx] = ef
                expl_rel[r_idx, c_idx] = er
                hint_faith[r_idx, c_idx] = hf
                hint_rel[r_idx, c_idx] = hr
        
        data_map[emb] = {
            'EF': expl_faith, 
            'ER': expl_rel, 
            'HF': hint_faith, 
            'HR': hint_rel
        }
        
    return data_map

def prepare_dataframe(data_map):
    records = []
    for emb in emb_sizes:
        d = data_map[emb]
        for r_idx, overlap in enumerate(chunk_overlaps):
            for c_idx, size in enumerate(chunk_sizes):
                records.append({
                    'Embedding': emb,
                    'Size': size,
                    'Overlap': overlap,
                    'Expl Faith': d['EF'][r_idx, c_idx],
                    'Expl Rel': d['ER'][r_idx, c_idx],
                    'Hint Faith': d['HF'][r_idx, c_idx],
                    'Hint Rel': d['HR'][r_idx, c_idx]
                })
    return pd.DataFrame(records)

def plot_trend_lines(df):
    filename = os.path.join('Result', 'RAGAS', 'Image', 'Evaluation_embedding_ES.png')
    fig, axes = plt.subplots(2, 3, figsize=(16, 12))
    fig.suptitle('Impact of Embedding Size on RAG Performance by Chunk Strategy', fontsize=20, fontweight='bold')

    for r_idx, overlap in enumerate(chunk_overlaps):
        for c_idx, size in enumerate(chunk_sizes):
            ax = axes[r_idx, c_idx]
            subset = df[(df['Size'] == size) & (df['Overlap'] == overlap)]
            x = subset['Embedding']
            
            ax.plot(x, subset['Expl Faith'], marker='o', label='Expl: Faithfulness', color='blue', linewidth=2, linestyle='-')
            ax.plot(x, subset['Expl Rel'],   marker='s', label='Expl: Relevancy',   color='green', linewidth=2, linestyle='--')
            ax.plot(x, subset['Hint Faith'], marker='^', label='Hint: Faithfulness', color='purple', linewidth=2, linestyle='-')
            ax.plot(x, subset['Hint Rel'],   marker='D', label='Hint: Relevancy',   color='orange', linewidth=2, linestyle='--')

            ax.set_title(f'Chunk Size: {size} / Overlap: {overlap}', fontsize=14, fontweight='bold', pad=10)
            ax.set_xlabel('Embedding Size (Dimension)')
            ax.set_ylabel('Score')
            ax.set_ylim(0.4, 1.0) 
            ax.set_xticks(emb_sizes)
            ax.grid(True, linestyle=':', alpha=0.6)
            
            ax.legend(loc='upper right', fontsize=10)

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])    
    plt.savefig(filename)

def plot_heatmaps(data_map):
    for emb_size, data in data_map.items():
        filename = os.path.join('Result', 'RAGAS', 'Image', f'rag_result_heatmap_e{emb_size}.png')
        df_ef = pd.DataFrame(data['EF'], index=chunk_overlaps, columns=chunk_sizes)
        df_er = pd.DataFrame(data['ER'], index=chunk_overlaps, columns=chunk_sizes)
        df_hf = pd.DataFrame(data['HF'], index=chunk_overlaps, columns=chunk_sizes)
        df_hr = pd.DataFrame(data['HR'], index=chunk_overlaps, columns=chunk_sizes)

        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        fig.suptitle(f'Performance Analysis - Embedding Size {emb_size}', fontsize=16, fontweight='bold')
        
        fmt = ".4f"
        kws = {"size": 13, "weight": "bold"}

        def plot(ax, df, title, color):
            sns.heatmap(df, annot=True, fmt=fmt, cmap=color, ax=ax, annot_kws=kws)
            ax.set_title(title, fontsize=12, fontweight='bold')
            ax.invert_yaxis()
            ax.set_xlabel('Chunk Size')
            ax.set_ylabel('Chunk Overlap')

        plot(axes[0,0], df_ef, 'Explanation: Faithfulness', 'Blues')
        plot(axes[0,1], df_hf, 'Hint: Faithfulness', 'Purples')
        plot(axes[1,0], df_er, 'Explanation: Relevancy', 'Greens')
        plot(axes[1,1], df_hr, 'Hint: Relevancy', 'Oranges')

        plt.tight_layout(rect=[0, 0.03, 1, 0.95])
        plt.savefig(filename)
        plt.close() 

def visualize_difficulty(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    items = []
    for item in data:
        items.append({
            "id": item["id"],
            "domain": extract_domain(item["id"]),
            "difficulty": item["predicted_difficulty"]
        })

    items = sorted(items, key=lambda x: x["difficulty"])

    diffs = [x["difficulty"] for x in items]
    domains = [x["domain"] for x in items]

    unique_domains = sorted(list(set(domains)))
    cmap = plt.get_cmap("tab10")
    domain_colors = {dom: cmap(i % 10) for i, dom in enumerate(unique_domains)}

    colors = [domain_colors[dom] for dom in domains]

    plt.figure(figsize=(12, 5))
    bars = plt.bar(range(len(diffs)), diffs, color=colors)

    plt.xticks([])

    plt.xlabel("Quiz Items (Sorted by Difficulty)", fontsize=12)
    plt.ylabel("Predicted Difficulty", fontsize=12)
    plt.title("Predicted Difficulty (Sorted, Colored by Domain)", fontsize=14)

    handles = [plt.Rectangle((0,0), 1, 1, color=domain_colors[d]) for d in unique_domains]
    plt.legend(handles, unique_domains, title="Domain", fontsize=10)

    cursor = mplcursors.cursor(bars, hover=True)

    @cursor.connect("add")
    def on_add(sel):
        idx = sel.index
        difficulty = diffs[idx]
        domain = domains[idx]
        qid = items[idx]["id"]
        sel.annotation.set(
            text=f"{qid}\nDomain: {domain}\nDifficulty: {difficulty:.3f}",
            fontsize=9
        )

    plt.tight_layout()
    plt.show()

def visualize_difficulty_by_domain(file_path, output_image='difficulty_analysis_domain.png'):
    print(f"데이터 분석 시작: {file_path}")

    try:
        df = pd.read_csv(file_path)
    except FileNotFoundError:
        print(f"오류: '{file_path}' 파일을 찾을 수 없습니다.")
        return

    new_cols = {
        df.columns[0]: 'Timestamp',
        df.columns[1]: 'Proficiency',
        df.columns[2]: 'Residence',
        df.columns[-1]: 'Feedback'
    }
    
    num_questions = (len(df.columns) - 4) // 2
    
    for i in range(1, num_questions + 1):
        ans_idx = 3 + (i-1)*2
        diff_idx = 4 + (i-1)*2
        new_cols[df.columns[ans_idx]] = f'Q{i}_Answer'
        new_cols[df.columns[diff_idx]] = f'Q{i}_Difficulty'
        
    df.rename(columns=new_cols, inplace=True)

    for i in range(1, num_questions + 1):
        df[f'Q{i}_Difficulty_Num'] = df[f'Q{i}_Difficulty'].apply(extract_difficulty)

    quiz_info = {
        'Q1': {'id': 'KIIP_economy_1', 'ans': '한강의 기적'},
        'Q2': {'id': 'KIIP_economy_49', 'ans': '근로계약서 작성'},
        'Q3': {'id': 'KIIP_geography_3', 'ans': '건조하고 화창하다'},
        'Q4': {'id': 'KIIP_geography_8', 'ans': '신라'},
        'Q5': {'id': 'KIIP_law_12', 'ans': '범죄를 수사하고 법을 집행하는 일'},
        'Q6': {'id': 'KIIP_law_34', 'ans': '공인 중개사를 통한다'},
        'Q7': {'id': 'KIIP_politics_5', 'ans': '간접민주주의'},
        'Q8': {'id': 'KIIP_politics_11', 'ans': '보통·평등·직접·비밀선거'},
        'Q9': {'id': 'KIIP_politics_30', 'ans': '정해진 법'},
        'Q10': {'id': 'KIIP_society_1', 'ans': '북한과 구별할 때'},
        'Q11': {'id': 'KIIP_society_15', 'ans': '1945년 일본의 지배에서 벗어나 독립을 맞이한 것을 기념하는 날'},
        'Q12': {'id': 'KIIP_tradition_4', 'ans': '외삼촌'},
        'Q13': {'id': 'KIIP_tradition_8', 'ans': '김치'},
        'Q14': {'id': 'KIIP_tradition_20', 'ans': '세뱃돈'},
        'Q15': {'id': 'KIIP_society_99', 'ans': '이사 후 전입신고를 하고 확정일자를 받는 것'}
    }

    quiz_stats = []
    
    for i in range(1, num_questions + 1):
        q_key = f'Q{i}'
        q_ans_col = f'{q_key}_Answer'
        q_diff_col = f'{q_key}_Difficulty_Num'
        
        info = quiz_info.get(q_key)
        
        if info:
            correct_answer = info['ans']
            quiz_id = info['id']
            
            domain = extract_domain(quiz_id)
            domain = domain.capitalize()

            is_correct = (df[q_ans_col] == correct_answer).astype(int)
            error_rate = 1 - is_correct.mean()
            avg_difficulty = df[q_diff_col].mean()
            
            quiz_stats.append({
                'Question': q_key,
                'Error_Rate': error_rate,
                'Avg_Perceived_Difficulty': avg_difficulty,
                'Domain': domain 
            })

    stats_df = pd.DataFrame(quiz_stats)

    plt.figure(figsize=(12, 8))

    sns.scatterplot(
        data=stats_df, 
        x='Avg_Perceived_Difficulty', 
        y='Error_Rate', 
        hue='Domain',   
        style='Domain',
        s=300,          
        palette='deep', 
        alpha=0.9
    )
    
    plt.axvline(x=stats_df['Avg_Perceived_Difficulty'].mean(), color='gray', linestyle=':', linewidth=1)
    plt.axhline(y=stats_df['Error_Rate'].mean(), color='gray', linestyle=':', linewidth=1)

    for i in range(stats_df.shape[0]):
        plt.text(
            stats_df.Avg_Perceived_Difficulty[i] + 0.03, 
            stats_df.Error_Rate[i], 
            stats_df.Question[i], 
            horizontalalignment='left', 
            size='medium', 
            color='black', 
            weight='bold'
        )
        
    plt.title('체감 난이도 vs 실제 오답률', fontsize=16, fontweight='bold', pad=20)
    plt.xlabel('평균 체감 난이도 (1:쉬움 ~ 5:어려움)', fontsize=12)
    plt.ylabel('실제 오답률 (0.0 ~ 1.0)', fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.legend(title='Quiz Domain', bbox_to_anchor=(1.05, 1), loc='upper left') 
    plt.tight_layout()
    
    plt.savefig(output_image)
    print(f"\n그래프가 '{output_image}' 파일로 저장되었습니다.")
    plt.show()

if __name__ == "__main__":
    visualize_difficulty_by_domain('Datasets\Data.csv')