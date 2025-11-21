package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizResultResponseDTO {
    private String resultMessage;
    private int totalExp;
    private String currentTier;
}
