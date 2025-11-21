package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignUpRequestDTO {
    private String email;
    private String password;
    private String nickname;
}
