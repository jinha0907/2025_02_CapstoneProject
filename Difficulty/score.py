import pandas as pd
import numpy as np
import re
import json
from dotenv import load_dotenv

load_dotenv()

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

def build_response_matrix(df_users, answer_key):
    user_ids = list(df_users.index.astype(str))
    item_ids = sorted(answer_key.keys(), key=lambda s: int(re.findall(r'\d+', s)[0]))
    n_users = len(user_ids)
    n_items = len(item_ids)
    
    R = np.full((n_users, n_items), np.nan, dtype=float)
    
    for u_idx, (uid, row) in enumerate(df_users.iterrows()):
        for j_idx, item_col in enumerate(item_ids):
            user_answer = row[item_col]
            correct_answer = answer_key[item_col]
            if pd.isna(user_answer): continue
            R[u_idx, j_idx] = 1.0 if user_answer == correct_answer else 0.0
            
    mask = ~np.isnan(R)
    return R, np.array(item_ids), mask

def fit_rasch_1pl(R, mask, n_iters=1500, lr=0.01, reg=1e-3):
    n_users, n_items = R.shape
    rng = np.random.default_rng(42)
    theta = rng.normal(0, 0.1, size=n_users)
    b = rng.normal(0, 0.1, size=n_items)
    
    for t in range(n_iters):
        lin = theta[:, None] - b[None, :]
        P = 1.0 / (1.0 + np.exp(-lin))
        diff = (R - P)
        diff[~mask] = 0.0
        
        grad_theta = np.sum(diff, axis=1) - reg * theta
        grad_b = -np.sum(diff, axis=0) - reg * b
        
        theta += lr * grad_theta
        b += lr * grad_b
        
        theta -= np.mean(theta)
        b -= np.mean(b)
        
    return b  

def preprocess_data(file_path):
    try:
        df = pd.read_csv(file_path)
    except FileNotFoundError:
        raise FileNotFoundError("File not found.")

    if df.iloc[0, 0] != "ANSWER_KEY":
        raise ValueError("Error: 첫 줄에 ANSWER_KEY가 필요합니다.")

    key_row = df.iloc[0]
    df_users = df.iloc[1:].copy()

    original_cols = df.columns
    new_cols = {
        original_cols[0]: 'Time',
        original_cols[1]: 'Prof',
        original_cols[2]: 'Res',
        original_cols[-1]: 'Feed'
    }

    num_q = (len(original_cols) - 4) // 2

    answer_key = {}
    for i in range(1, num_q + 1):
        ans_idx = 3 + (i - 1) * 2
        diff_idx = 4 + (i - 1) * 2

        q_ans = f"Q{i}_Answer"
        q_diff = f"Q{i}_Difficulty"

        new_cols[original_cols[ans_idx]] = q_ans
        new_cols[original_cols[diff_idx]] = q_diff

        answer_key[q_ans] = key_row.iloc[ans_idx]

    df_users.rename(columns=new_cols, inplace=True)

    for i in range(1, num_q + 1):
        df_users[f"Q{i}_Difficulty_Num"] = df_users[f"Q{i}_Difficulty"].apply(extract_difficulty)

    df_users["Prof_Group"] = df_users["Prof"].apply(simplify_prof)

    return df_users, answer_key, num_q

def compute_irt_scores(df_users, answer_key):
    R, item_ids, mask = build_response_matrix(df_users, answer_key)
    b_values = fit_rasch_1pl(R, mask)

    b_min, b_max = np.min(b_values), np.max(b_values)
    if b_max > b_min:
        irt_scores_1to5 = 1 + (b_values - b_min) / (b_max - b_min) * 4
    else:
        irt_scores_1to5 = np.full_like(b_values, 3.0)

    return irt_scores_1to5, item_ids

def compute_padi_scores(df_users, num_q):
    prof_weights = {'Advanced': 3, 'Intermediate': 2, 'Beginner': 1, 'Unknown': 0}
    df_users['W'] = df_users['Prof_Group'].map(prof_weights)

    subj_scores_1to5 = []

    for i in range(1, num_q + 1):
        ratings = df_users[f"Q{i}_Difficulty_Num"]
        mask_valid = ~ratings.isna()

        if mask_valid.sum() > 0:
            w_sum = np.sum(ratings[mask_valid] * df_users.loc[mask_valid, 'W'])
            w_count = df_users.loc[mask_valid, 'W'].sum()
            score = w_sum / w_count if w_count > 0 else 3.0
        else:
            score = 3.0

        subj_scores_1to5.append(score)

    subj_scores_1to5 = np.array(subj_scores_1to5)

    p_min, p_max = subj_scores_1to5.min(), subj_scores_1to5.max()
    if p_max > p_min:
        padi_scores_1to5 = 1 + (subj_scores_1to5 - p_min) / (p_max - p_min) * 4
    else:
        padi_scores_1to5 = np.full_like(subj_scores_1to5, 3.0)

    return padi_scores_1to5


def compute_hybrid_scores(irt_scores, padi_scores, alpha=0.6):
    return alpha * irt_scores + (1 - alpha) * padi_scores

def show_hybrid_difficulty(item_ids, final_scores, irt_scores, padi_scores, answer_key):
    results = []

    for idx, q_id in enumerate(item_ids):
        q_name = "Q" + re.findall(r'\d+', q_id)[0]
        results.append({
            "Question": q_name,
            "Final_Score": final_scores[idx],
            "IRT_Score_Norm": irt_scores[idx],
            "Subjective_Score": padi_scores[idx],
            "Correct_Answer": answer_key[q_id]
        })

    result_df = pd.DataFrame(results).sort_values("Final_Score", ascending=False)
    return result_df

def calculate_hybrid_difficulty(file_path, alpha=0.6):
    df_users, answer_key, num_q = preprocess_data(file_path)

    irt_scores, item_ids = compute_irt_scores(df_users, answer_key)
    padi_scores = compute_padi_scores(df_users, num_q)
    final_scores = compute_hybrid_scores(irt_scores, padi_scores, alpha)

    result_df = show_hybrid_difficulty(item_ids, final_scores, irt_scores, padi_scores, answer_key)

    return result_df

def attach_difficulty_to_survey(survey_json_path, difficulty_df, output_path=None):
    with open(survey_json_path, "r", encoding="utf-8") as f:
        survey = json.load(f)

    diff_map = {}
    for _, row in difficulty_df.iterrows():
        correct = row["Correct_Answer"]
        diff_map[correct] = {
            "irt": float(row["IRT_Score_Norm"]),
            "padi": float(row["Subjective_Score"]),
            "hybrid": float(row["Final_Score"])
        }


    updated_survey = []
    for item in survey:

        ans = item.get("answer")

        if ans in diff_map:
            item["difficulty"] = diff_map[ans]

        updated_survey.append(item)


    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(updated_survey, f, ensure_ascii=False, indent=4)

    return updated_survey

if __name__ == "__main__":
    alpha = 0.6
    result_df = calculate_hybrid_difficulty("Datasets\Data.csv")

    updated = attach_difficulty_to_survey(
    survey_json_path="survey.json",
    difficulty_df=result_df,
    output_path=f"survey_with_difficulty_{alpha}.json"
)