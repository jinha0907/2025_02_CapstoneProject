package com.team06.hanq.entity;

import java.time.LocalDate;
import lombok.*;
import jakarta.persistence.*;

@Entity
@Table(name = "learning_stats")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LearningStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long statId;

    @Column(nullable = false)
    private Long userId;

    private LocalDate date = LocalDate.now();

    private int totalQuizzes;
    private int correctQuizzes;
}

