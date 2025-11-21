package com.team06.hanq.entity;

import lombok.*;
import jakarta.persistence.*;

@Entity
@Table(name = "quiz_header")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizHeader {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long quizId;

    private String category;

    @Enumerated(EnumType.STRING)
    private Difficulty difficulty;

    public enum Difficulty {
        EASY, NORMAL, HARD
    }
}
