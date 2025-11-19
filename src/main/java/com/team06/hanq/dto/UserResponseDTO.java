package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long userId;
    private String email;
    private String nickname;
    private String tier;
    private int totalExp;
    private String difficulty;
    private int questionCount;
}

