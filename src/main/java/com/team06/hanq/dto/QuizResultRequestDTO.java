    package com.team06.hanq.dto;

    import lombok.*;
    import java.util.List;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public class QuizResultRequestDTO {
        private Long userId;
        private List<Long> quizId;
        private int correctCount;
        private int totalCount;
        private int score;          // 예: 100점 만점
        private int earnedExp;      // 이번 퀴즈로 획득한 경험치
    }
