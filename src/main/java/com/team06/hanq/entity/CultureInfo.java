package com.team06.hanq.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "culture_information")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CultureInfo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long infoId;

    @Column(nullable = false)
    private String title;

    private String subtitle;
    private String subsubtitle;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String explanation;
}
