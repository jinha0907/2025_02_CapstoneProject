package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettingsResponseDTO {
    private String difficulty;
    private int questionCount;
}
