package com.team06.hanq.exception;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ErrorResponse {
    private String code;
    private String message;
    private int status;         // HTTP 상태 코드
    private LocalDateTime timestamp;
}
