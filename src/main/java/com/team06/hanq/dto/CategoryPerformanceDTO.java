package com.team06.hanq.dto;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryPerformanceDTO {

    private Long userId;
    private List<CategoryStat> mostCorrect;
    private List<CategoryStat> mostWrong;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CategoryStat {
        private String category;
        private long count;
    }
}
