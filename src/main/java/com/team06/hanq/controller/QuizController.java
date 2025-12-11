package com.team06.hanq.controller;

import com.team06.hanq.config.ApiResponseDocs;
import com.team06.hanq.dto.QuizResultRequestDTO;
import com.team06.hanq.dto.QuizResultResponseDTO;
import com.team06.hanq.dto.UserAccuracyDTO;
import com.team06.hanq.entity.QuizDetails;
import com.team06.hanq.service.QuizService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.team06.hanq.dto.CategoryStatsDTO;

import java.util.List;

@RestController
@RequestMapping("/quiz")
@RequiredArgsConstructor
@Tag(name = "Quiz", description = "퀴즈 관련 API (문제 불러오기, 결과 저장)")
public class QuizController {

    private final QuizService quizService;

    // 오늘의 퀴즈 불러오기
    @Operation(summary = "사용자 맞춤 퀴즈 불러오기", description = "유저의 학습량(questionCount)만큼 문제를 불러옵니다. 일부는 복습 문제로 포함됩니다.")
    @ApiResponse(responseCode = "200" ,description = "퀴즈 불러오기 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @GetMapping("/load/{userId}")
    public List<QuizDetails> getQuizForUser(@PathVariable Long userId) {
        return quizService.getQuizForUser(userId);
    }

    @Operation(summary = "사용자의 퀴즈 결과 가져오기")
    @ApiResponse(responseCode = "200", description = "결과 저장 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @PostMapping("/result")
    public QuizResultResponseDTO saveQuizResult(@RequestBody QuizResultRequestDTO request) {
        return quizService.saveQuizResult(request);
    }

    @GetMapping("/stats/accuracy/{userId}")
    @Operation(summary = "유저 정답률 조회", description = "해당 유저의 전체 퀴즈 정답률을 반환합니다.")
    public ResponseEntity<UserAccuracyDTO> getUserAccuracy(@PathVariable Long userId) {
        return ResponseEntity.ok(quizService.getUserAccuracy(userId));
    }

    @GetMapping("/stats/category/{userId}")
    @Operation(summary = "유저 카테고리별 푼 문제 수 조회", description = "전체 카테고리 중 유저가 푼 문제 수를 반환합니다.")
    @ApiResponse(responseCode = "200", description = "카테고리별 문제 수 조회 성공")
    @ApiResponseDocs.DefaultErrorResponses
    public ResponseEntity<CategoryStatsDTO> getSolvedByCategory(@PathVariable Long userId) {
        return ResponseEntity.ok(quizService.getSolvedByCategory(userId));
    }

}
