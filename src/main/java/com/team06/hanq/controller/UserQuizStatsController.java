package com.team06.hanq.controller;

import com.team06.hanq.config.ApiResponseDocs;
import com.team06.hanq.service.UserQuizStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/user/quiz")
@RequiredArgsConstructor
@Tag(name = "User Quiz Stats", description = "유저 퀴즈 통계 API (총합 / 주간)")
public class UserQuizStatsController {

    private final UserQuizStatsService quizStatsService;

    @Operation(summary = "유저 푼 문제 총 개수 조회")
    @ApiResponse(responseCode = "200", description = "문제 개수 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/total/{userId}")
    public int getTotalSolvedQuizzes(@PathVariable Long userId) {
        return quizStatsService.getTotalSolvedQuizzes(userId);
    }

    @Operation(summary = "유저 일주일 학습 현황 조회")
    @ApiResponse(responseCode = "200", description = "학습 현황 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/weekly/{userId}")
    public List<Map<String, Object>> getWeeklyStats(@PathVariable Long userId) {
        return quizStatsService.getWeeklyStats(userId);
    }
}
