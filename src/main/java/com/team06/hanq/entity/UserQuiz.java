package com.team06.hanq.entity;

import lombok.*;
import jakarta.persistence.*;

@Entity
@Table(name = "user_quiz")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(UserQuizId.class)
public class UserQuiz {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @Id
    @Column(name = "quiz_id")
    private Long quizId;
}

