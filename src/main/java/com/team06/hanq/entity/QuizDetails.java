package com.team06.hanq.entity;

import lombok.*;
import jakarta.persistence.*;

@Entity
@Table(name = "quiz_details")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuizDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long detailId;

    @ManyToOne
    @JoinColumn(name = "quiz_id")
    private QuizHeader quizHeader;

    @Column(nullable = false)
    private String question;

    @Column(nullable = false, columnDefinition = "JSON")
    private String choices;

    @Column(nullable = false)
    private String answer;

    @Column(columnDefinition = "JSON")
    private String explanation;
}

