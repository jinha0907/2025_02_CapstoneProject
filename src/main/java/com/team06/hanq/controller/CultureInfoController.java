package com.team06.hanq.controller;

import com.team06.hanq.entity.CultureInfo;
import com.team06.hanq.service.CultureInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/culture")
@RequiredArgsConstructor
public class CultureInfoController {

    private final CultureInfoService service;

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

