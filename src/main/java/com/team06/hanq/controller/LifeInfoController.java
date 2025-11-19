package com.team06.hanq.controller;

import com.team06.hanq.dto.LifeInfoDTO;
import com.team06.hanq.service.LifeInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/life")
@RequiredArgsConstructor
public class LifeInfoController {

    private final LifeInfoService service;

    // 1️⃣ 전체 타이틀 목록
    @GetMapping("/titles")
    public List<String> getAllTitles() {
        return service.getAllTitles();
    }

    // 2️⃣ 특정 타이틀의 서브타이틀 목록
    @GetMapping("/title/{title}/subtitles")
    public List<LifeInfoDTO> getSubtitlesByTitle(@PathVariable String title) {
        return service.getSubtitlesByTitle(title);
    }

    // 3️⃣ 상세 조회
    @GetMapping("/{infoId}")
    public LifeInfoDTO getLifeInfoDetail(@PathVariable Long infoId) {
        return service.getLifeInfoDetail(infoId);
    }
}

