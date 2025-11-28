package com.team06.hanq.controller;

import com.team06.hanq.config.ApiResponseDocs;
import com.team06.hanq.dto.LifeInfoDTO;
import com.team06.hanq.service.LifeInfoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/life")
@RequiredArgsConstructor
@Tag(name = "Life Info", description = "생활 정보 (줄글) 관련 API")
public class LifeInfoController {

    private final LifeInfoService service;

    // 전체 타이틀 목록
    @Operation(summary = "DB의 모든 생활 정보 title 조회")
    @ApiResponse(responseCode = "200", description = "문화 정보 title 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/titles")
    public List<String> getAllTitles() {
        return service.getAllTitles();
    }

    // 특정 타이틀의 서브타이틀 목록
    @Operation(summary = "DB의 모든 생활 정보 subtitle 조회")
    @ApiResponse(responseCode = "200", description = "문화 정보 subtitle 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/title/{title}/subtitles")
    public List<LifeInfoDTO> getSubtitlesByTitle(@PathVariable String title) {
        return service.getSubtitlesByTitle(title);
    }

    // 상세 조회
    @Operation(summary = "특정 정보의 내용 상세 조회")
    @ApiResponse(responseCode = "200", description = "문화 정보 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/{infoId}")
    public LifeInfoDTO getLifeInfoDetail(@PathVariable Long infoId) {
        return service.getLifeInfoDetail(infoId);
    }
}

