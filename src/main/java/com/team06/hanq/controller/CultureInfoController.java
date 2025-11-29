package com.team06.hanq.controller;

import com.team06.hanq.config.ApiResponseDocs;
import com.team06.hanq.entity.CultureInfo;
import com.team06.hanq.service.CultureInfoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/culture")
@RequiredArgsConstructor
@Tag(name = "Culture Info", description = "문화 정보(퀴즈 줄글) 관련 API")
public class CultureInfoController {

    private final CultureInfoService service;

    @Operation(summary = "문화 정보의 title 조회", description = "List로 반환합니다.")
    @ApiResponse(responseCode = "200", description = "문화 정보 title 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/titles")
    public List<String> getAllTitles() {
        return service.getAllTitles();
    }

    @Operation(summary = "문화 정보의 title 별 subttile 목록 조회")
    @ApiResponse(responseCode = "200", description = "문화 정보 subtitle 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/title/{title}/subtitles")
    public List<CultureInfo> getSubtitlesByTitle(@PathVariable String title) {
        return service.getSubtitlesByTitle(title);
    }


    @Operation(summary = "문화 정보의 title 별 subttile 목록 조회")
    @ApiResponse(responseCode = "200", description = "문화 정보 subsubtitle 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/title/{subtitle}/subsubtitles")
    public List<CultureInfo> getSubsubtitlesBySubtitle(@PathVariable String subtitle) {
        return service.getSubsubtitlesBySubtitle(subtitle);
    }

    @Operation(summary = "특정 id의 문화 정보 조회")
    @ApiResponse(responseCode = "200", description = "문화 정보 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/{infoId}")
    public CultureInfo getDetail(@PathVariable Long infoId) {
        return service.getDetail(infoId);
    }
}

