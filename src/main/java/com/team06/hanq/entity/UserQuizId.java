package com.team06.hanq.entity;

import lombok.*;
import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserQuizId implements Serializable {
    private Long userId;
    private Long quizId;
}

