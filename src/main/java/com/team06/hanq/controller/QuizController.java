package com.team06.hanq.controller;

import com.team06.hanq.dto.QuizResultRequestDTO;
import com.team06.hanq.dto.QuizResultResponseDTO;
import com.team06.hanq.entity.QuizDetails;
import com.team06.hanq.service.QuizService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/quiz")
@RequiredArgsConstructor
@Tag(name = "Quiz", description = "퀴즈 관련 API (문제 불러오기, 결과 저장)")
public class QuizController {

    private final QuizService quizService;

    // ✅ 1️⃣ 오늘의 퀴즈 불러오기
    @Operation(summary = "사용자 맞춤 퀴즈 불러오기", description = "유저의 학습량(questionCount)만큼 문제를 불러옵니다. 일부는 복습 문제로 포함됩니다.")
    @GetMapping("/load/{userId}")
    public List<QuizDetails> getQuizForUser(@PathVariable Long userId) {
        return quizService.getQuizForUser(userId);
    }

    @PostMapping("/result")
    public QuizResultResponseDTO saveQuizResult(@RequestBody QuizResultRequestDTO request) {
        return quizService.saveQuizResult(request);
    }

}
