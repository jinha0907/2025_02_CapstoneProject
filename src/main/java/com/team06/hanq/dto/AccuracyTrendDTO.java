package com.team06.hanq.dto;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AccuracyTrendDTO {
    private Long userId;
    private int periodDays;
    private List<DailyAccuracy> trend;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DailyAccuracy {
        private String date;
        private int total;
        private int correct;
        private double accuracy;
    }
}
