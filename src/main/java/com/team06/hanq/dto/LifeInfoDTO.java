package com.team06.hanq.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LifeInfoDTO {
    private Long infoId;
    private String title;
    private String subtitle;
    private String explanation;
}

