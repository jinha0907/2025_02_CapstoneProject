import json, os
import pandas as pd
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()
client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])


def build_fewshot_prompt(fewshot_path):
    with open(fewshot_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    blocks = []
    for item in data:

        diff = item.get("difficulty", {})
        irt = diff.get("irt", "N/A")
        padi = diff.get("padi", "N/A")
        hybrid = diff.get("hybrid", "N/A")

        block = (
            "[Example]\n"
            f"Question: {item['question']}\n"
            f"Choices: {' | '.join(item['choices'])}\n"
            f"Answer: {item['answer']}\n"
            f"IRT_Score: {irt}\n"
            f"PADI_Score: {padi}\n"
            f"Hybrid_Score: {hybrid}\n"
            "Explanation: Difficulty is computed as Hybrid_Score = 0.6 * IRT_Score + 0.4 * PADI_Score\n"
            f"Difficulty: {hybrid}\n"
        )
        blocks.append(block)

    return "\n".join(blocks)


def predict_difficulty_llm(question_item, fewshot_prompt):
    user_query = (
        "아래는 난이도(Hybrid_Score)가 이미 부여된 예시들이다.\n"
            "각 예시는 IRT_Score, PADI_Score, Hybrid_Score를 포함한다.\n"
            "\n"
            "[Difficulty Calculation Rules]\n"
            "- IRT_Score는 객관적 문항 난이도 (정답률 기반)이며 낮을수록 쉽다"
            "- PADI_Score는 사용자의 주관 난이도 평가 기반 가중 평균이다.\n"
            "  Beginner=1, Intermediate=2, Advanced=3 의 가중치를 사용하여\n"
            "  PADI_raw = Σ(difficulty_i × weight_i) / Σ(weight_i) 로 계산된다.\n"
            "- 이후 PADI_raw 값들을 Min-Max Scaling하여 1~5 구간으로 정규화한 값이 PADI_Score이다.\n"
            "- Hybrid_Score는 IRT_Score와 PADI_Score를 결합한 최종 난이도이며,\n"
            "  Hybrid_Score = 0.6 * IRT_Score + 0.4 * PADI_Score 로 계산된다.\n"
            "\n"
            "이 규칙과 아래 예시들(few-shot example)을 참고하여,\n"
            "주어진 새로운 문제의 Hybrid 난이도(1~5 사이 실수)를 예측하라.\n"
        "출력은 다음 구조의 JSON 객체만 허용된다:\n"
        '{"difficulty": <float>}\n\n'
        + fewshot_prompt +
        "\n\n[Task]\n"
        f"Question: {question_item['question']}\n"
        f"Choices: {' | '.join(question_item['choices'])}\n"
        f"Answer: {question_item['answer']}\n\n"
        "Output ONLY JSON as specified."
    )

    response = client.chat.completions.create(
        model="gpt-4o",
        response_format={"type": "json_object"},
        messages=[{"role": "user", "content": user_query}],
        temperature=0.2
    )

    result_json = json.loads(response.choices[0].message.content)

    diff = result_json.get("difficulty", None)
    return diff


def generate_difficulty_for_new_quiz_llm(fewshot_json_path, new_quiz_json_path, output_path):
    fewshot_prompt = build_fewshot_prompt(fewshot_json_path)

    with open(new_quiz_json_path, "r", encoding="utf-8") as f:
        new_data = json.load(f)

    new_results = []
    for item in new_data:
        q_id = item.get("id", None)
        print(f"[LLM] Processing ID: {q_id}")

        predicted_diff = predict_difficulty_llm(item, fewshot_prompt)
        item_with_diff = item.copy()
        item_with_diff["predicted_difficulty"] = predicted_diff
        new_results.append(item_with_diff)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(new_results, f, ensure_ascii=False, indent=4)

    return new_results

def group_by_custom_bins(json_path, bins, output_path):
    """
    bins = [1.0, 1.5, 2.0, 3.0, 5.0] 처럼 사용자가 직접 설정한 경계값 리스트
    """

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    df = pd.DataFrame(data)

    labels = ["SO EASY", "EASY", "NORMAL", "HARD", "SO HARD"]

    df["difficulty_group"] = pd.cut(
        df["predicted_difficulty"],
        bins=bins,
        labels=labels,
        include_lowest=True,
        right=False   
    )

    grouped_data = df.to_dict(orient="records")

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(grouped_data, f, ensure_ascii=False, indent=4)

    return df


if __name__ == "__main__":
    df = group_by_custom_bins("selected_difficulty.json", [1, 1.5, 2.2, 2.6, 3.0, 5.0], "selected_difficulty_5.json")
