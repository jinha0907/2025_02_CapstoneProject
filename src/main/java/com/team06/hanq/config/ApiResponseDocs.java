package com.team06.hanq.config;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;

public class ApiResponseDocs {

    @ApiResponses({
            @ApiResponse(responseCode = "400", description = "잘못된 요청 (유효성 검증 실패)",
                    content = @Content(mediaType = "application/json", schema = @Schema(ref = "ErrorResponse"))),
            @ApiResponse(responseCode = "404", description = "리소스를 찾을 수 없음",
                    content = @Content(mediaType = "application/json", schema = @Schema(ref = "ErrorResponse"))),
            @ApiResponse(responseCode = "500", description = "서버 내부 오류",
                    content = @Content(mediaType = "application/json", schema = @Schema(ref = "ErrorResponse")))
    })
    public @interface DefaultErrorResponses {
    }
}
