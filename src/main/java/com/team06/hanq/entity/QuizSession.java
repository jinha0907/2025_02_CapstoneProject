package com.team06.hanq.entity;

import jakarta.persistence.*;
import lombok.*;
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

    private Long userId;
    private Long quizId;

    // 문제 정답 여부
    private boolean isCorrect;

    // 동일 문제 재도전 시 카운트
    private int attemptCount;

    // 점수 및 전체 문제 수 (세트 단위)
    private int score;
    private int totalCount;

    private LocalDateTime startedAt;
    private LocalDateTime finishedAt;
}
