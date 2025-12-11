package com.team06.hanq.dto;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryStatsDTO {

    private Long userId;
    private List<CategoryCount> categories;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CategoryCount {
        private String category;
        private long solvedCount;
    }
}
