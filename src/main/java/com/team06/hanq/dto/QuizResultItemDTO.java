package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizResultItemDTO {
    private Long quizId;
    private boolean isCorrect;  // 문제별 정답 여부
}
