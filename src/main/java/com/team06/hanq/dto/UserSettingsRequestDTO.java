package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettingsRequestDTO {
    private String difficulty;
    private int questionCount;
}
