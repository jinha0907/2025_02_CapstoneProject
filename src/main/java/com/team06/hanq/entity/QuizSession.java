package com.team06.hanq.entity;

import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "quiz_session")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long sessionId;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private Long quizId;

    private int score;
    private int correctCount;
    private int totalCount;

    private LocalDateTime startedAt;
    private LocalDateTime finishedAt;
}

