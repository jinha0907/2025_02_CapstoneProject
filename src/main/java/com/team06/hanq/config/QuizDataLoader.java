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
            File file = new File("src/main/resources/made_by_PDFRAG.json");
            if (!file.exists()) {
                System.out.println("⚠️ Quiz JSON file not found — skipping load.");
                return;
            }

            List<QuizJsonRecord> quizList = objectMapper.readValue(file, new TypeReference<>() {});

            for (QuizJsonRecord item : quizList) {
                // 🔹 category 추출 (예: "KIIP_economy_1" → "economy")
                String[] parts = item.getId().split("_");
                String category = parts.length > 1 ? parts[1] : "general";

                // 🔹 quiz_header 생성
                QuizHeader header = QuizHeader.builder()
                        .category(category)
                        .difficulty(QuizHeader.Difficulty.NORMAL)
                        .build();
                quizHeaderRepo.save(header);

                // 🔹 quiz_details 생성
                QuizDetails details = QuizDetails.builder()
                        .quizHeader(header)
                        .question(item.getQuestion())
                        .choices(objectMapper.writeValueAsString(item.getChoices()))
                        .answer(item.getAnswer())
                        .explanation(objectMapper.writeValueAsString(item.getExplanation()))
                        .build();
                quizDetailsRepo.save(details);
            }

            System.out.println("✅ Loaded " + quizList.size() + " quiz records from made_by_PDFRAG.json");

        } catch (Exception e) {
            System.err.println("❌ Failed to load quiz data: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // 내부용 DTO 클래스
    @lombok.Data
    static class QuizJsonRecord {
        private String id;
        private String paragraph;
        private String question;
        private List<String> choices;
        private String answer;
        private List<String> explanation;
    }
}
