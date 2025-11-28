package com.team06.hanq.controller;

import com.team06.hanq.config.ApiResponseDocs;
import com.team06.hanq.dto.UserSettingsRequestDTO;
import com.team06.hanq.dto.UserSettingsResponseDTO;
import com.team06.hanq.service.UserSettingsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users/{userId}/settings")
@RequiredArgsConstructor
@Tag(name = "User Settings", description = "유저 설정 관련 API(일 학습량 / 난이도)")
public class UserSettingsController {

    private final UserSettingsService service;

    @Operation(summary = "유저 설정 조회 (난이도, 학습량)")
    @ApiResponse(responseCode = "200", description = "유저 설정 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping
    public UserSettingsResponseDTO getSettings(@PathVariable Long userId) {
        return service.getUserSettings(userId);
    }

    @Operation(summary = "유저 난이도 변경")
    @ApiResponse(responseCode = "200", description = "유저 난이도 변경 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @PutMapping("/difficulty")
    public UserSettingsResponseDTO updateDifficulty(@PathVariable Long userId, @RequestParam String difficulty) {
        return service.updateDifficulty(userId, difficulty);
    }

    @Operation(summary = "유저 학습량 변경")
    @ApiResponse(responseCode = "200", description = "유저 학습량 변경 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @PutMapping("/question-count")
    public UserSettingsResponseDTO updateQuestionCount(@PathVariable Long userId, @RequestParam int count) {
        return service.updateQuestionCount(userId, count);
    }
}
