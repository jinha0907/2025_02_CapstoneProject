package com.team06.hanq.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.team06.hanq.entity.QuizDetails;
import com.team06.hanq.entity.QuizHeader;
import com.team06.hanq.repository.QuizDetailsRepository;
import com.team06.hanq.repository.QuizHeaderRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.io.File;
import java.util.List;

@Component
@RequiredArgsConstructor
public class QuizDataLoader {

    private final QuizHeaderRepository quizHeaderRepo;
    private final QuizDetailsRepository quizDetailsRepo;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostConstruct
    public void loadQuizData() {
        try {
            File file = new File("/home/ubuntu/made_by_PDFRAG.json");
            if (!file.exists()) {
                System.out.println("⚠️ Quiz JSON file not found — skipping load.");
                return;
            }

            // JSON 파일 → Java 객체 리스트 변환
            List<QuizJsonRecord> quizList = objectMapper.readValue(file, new TypeReference<>() {});
            int inserted = 0;
            int skipped = 0;

            for (QuizJsonRecord item : quizList) {
                // 이미 동일한 question이 있으면 skip
                boolean exists = quizDetailsRepo.existsByQuestion(item.getQuestion());
                if (exists) {
                    skipped++;
                    continue;
                }

                // category 추출 ("KIIP_economy_1" → "economy")
                String[] parts = item.getId().split("_");
                String category = parts.length > 1 ? parts[1] : "general";

                // difficulty_group → Enum 매핑
                QuizHeader.Difficulty difficulty = mapDifficulty(item.getDifficultyGroup());

                // QuizHeader 생성
                QuizHeader header = QuizHeader.builder()
                        .category(category)
                        .difficulty(difficulty)
                        .build();
                quizHeaderRepo.save(header);

                // QuizDetails 생성
                QuizDetails details = QuizDetails.builder()
                        .quizHeader(header)
                        .question(item.getQuestion())
                        .choices(objectMapper.writeValueAsString(item.getChoices()))
                        .answer(item.getAnswer())
                        .explanation(item.getExplanation()) // String으로 단일 해설 저장
                        .build();
                quizDetailsRepo.save(details);

                inserted++;
            }

            System.out.println("✅ Quiz JSON load complete: " +
                    inserted + " inserted, " + skipped + " skipped.");

        } catch (Exception e) {
            System.err.println("❌ Failed to load quiz data: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * difficulty_group → Enum 매핑
     * 예: "SO HARD" → HARD, "EASY" → EASY 등
     */
    private QuizHeader.Difficulty mapDifficulty(String group) {
        if (group == null) return QuizHeader.Difficulty.NORMAL;

        String normalized = group.trim().toUpperCase();
        return switch (normalized) {
            case "SO EASY", "EASY" -> QuizHeader.Difficulty.EASY;
            case "NORMAL" -> QuizHeader.Difficulty.NORMAL;
            case "HARD", "SO HARD" -> QuizHeader.Difficulty.HARD;
            default -> QuizHeader.Difficulty.NORMAL;
        };
    }

    // 내부 JSON 구조 매핑 클래스
    @lombok.Data
    static class QuizJsonRecord {
        private String id;
        private String question;
        private List<String> choices;
        private String answer;
        private String explanation;
        private String hint;
        private String difficultyGroup;     // ✅ Enum 매핑용
        private Double predictedDifficulty; // 🚫 무시됨
        private List<String> contexts;      // 🚫 무시됨
    }
}
