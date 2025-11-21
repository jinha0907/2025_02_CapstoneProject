package com.team06.hanq.controller;

import com.team06.hanq.entity.CultureInfo;
import com.team06.hanq.service.CultureInfoService;
import io.swagger.v3.oas.annotations.Operation;
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
    @GetMapping("/titles")
    public List<String> getAllTitles() {
        return service.getAllTitles();
    }

    @GetMapping("/title/{title}/subtitles")
    public List<CultureInfo> getSubtitlesByTitle(@PathVariable String title) {
        return service.getSubtitlesByTitle(title);
    }

    @GetMapping("/{infoId}")
    public CultureInfo getDetail(@PathVariable Long infoId) {
        return service.getDetail(infoId);
    }
}

