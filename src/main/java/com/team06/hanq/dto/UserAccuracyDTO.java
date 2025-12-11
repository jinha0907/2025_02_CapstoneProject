package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserAccuracyDTO {
    private Long userId;
    private int totalQuizzes;     // 총 푼 문제 수
    private int correctQuizzes;   // 맞춘 문제 수
    private double accuracy;      // 정답률 (0~1)
}
