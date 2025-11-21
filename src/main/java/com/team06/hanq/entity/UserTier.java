package com.team06.hanq.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_tier")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserTier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long tierId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TierName tierName;

    @Column(nullable = false)
    private int minExp;

    @Column(nullable = false)
    private int maxExp;

    public enum TierName {
        BRONZE, SILVER, GOLD, PLATINUM
    }
}
