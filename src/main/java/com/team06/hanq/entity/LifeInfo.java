package com.team06.hanq.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "life_information")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LifeInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long infoId;              // PK

    @Column(nullable = false)
    private String title;             // 대분류 (예: 은행 업무)

    private String subtitle;          // 중분류 (예: 계좌 개설)

    @Column(nullable = false, columnDefinition = "TEXT")
    private String explanation;      // 설명문
}

