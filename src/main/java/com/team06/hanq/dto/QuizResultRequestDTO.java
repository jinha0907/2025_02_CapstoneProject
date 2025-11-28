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
    private List<QuizResultItemDTO> results; // 문제별 결과 리스트
    private int totalCount;
    private int score;
    private int earnedExp;
}
