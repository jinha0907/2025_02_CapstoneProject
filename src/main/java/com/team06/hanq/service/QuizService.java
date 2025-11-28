package com.team06.hanq.service;

import com.team06.hanq.dto.QuizResultRequestDTO;
import com.team06.hanq.dto.QuizResultResponseDTO;
import com.team06.hanq.entity.*;
import com.team06.hanq.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizDetailsRepository quizDetailsRepo;
    private final UserSettingsRepository settingsRepo;
    private final UserQuizRepository userQuizRepo;
    private final QuizSessionRepository quizSessionRepo;
    private final LearningStatsRepository learningStatsRepo;
    private final UserRepository userRepo;
    private final UserTierRepository tierRepo;

    // 사용자에게 오늘의 퀴즈 불러오기
    public List<QuizDetails> getQuizForUser(Long userId) {
        // 사용자 설정 불러오기
        UserSettings settings = settingsRepo.findByUser_UserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("유저 설정 정보를 찾을 수 없습니다."));

        int questionCount = settings.getQuestionCount();
        int reviewCount = (questionCount <= 5) ? 1 : 2;
        int newCount = questionCount - reviewCount;

        // 유저가 틀린 문제 목록 가져오기
        List<Long> wrongQuizIds = quizSessionRepo.findByUserIdAndQuizId(userId, null)
                .stream()
                .filter(session -> session.getCorrectCount() < session.getTotalCount())
                .map(session -> session.getQuizId())
                .collect(Collectors.toList());

        // 복습 문제 추출
        List<QuizDetails> reviewQuizzes = new ArrayList<>();
        if (!wrongQuizIds.isEmpty()) {
            Collections.shuffle(wrongQuizIds);
            List<Long> selectedIds = wrongQuizIds.stream()
                    .limit(reviewCount)
                    .collect(Collectors.toList());
            reviewQuizzes.addAll(quizDetailsRepo.findAllById(selectedIds));
        } else {
            // 틀린 문제가 부족하면 랜덤 문제로 대체
            reviewQuizzes.addAll(quizDetailsRepo.findRandomQuizzes(reviewCount));
        }

        // 새 문제 추출
        List<QuizDetails> newQuizzes = quizDetailsRepo.findRandomQuizzes(newCount);

        // 문제 통합
        List<QuizDetails> finalList = new ArrayList<>();
        finalList.addAll(reviewQuizzes);
        finalList.addAll(newQuizzes);
        Collections.shuffle(finalList);

        return finalList;
    }

    public QuizResultResponseDTO saveQuizResult(QuizResultRequestDTO req) {
        // quiz_session 저장
        for(Long qid : req.getQuizId()) {
            QuizSession session = QuizSession.builder()
                    .userId(req.getUserId())
                    .quizId(qid)
                    .score(req.getScore())
                    .correctCount(req.getCorrectCount())
                    .totalCount(req.getTotalCount())
                    .startedAt(LocalDateTime.now().minusMinutes(5))
                    .finishedAt(LocalDateTime.now())
                    .build();
            quizSessionRepo.save(session);
        }


        // learning_stats 갱신
        LearningStats stats = learningStatsRepo.findByUserIdAndDate(req.getUserId(), LocalDate.now())
                .orElse(LearningStats.builder()
                        .userId(req.getUserId())
                        .date(LocalDate.now())
                        .totalQuizzes(0)
                        .correctQuizzes(0)
                        .build());
        stats.setTotalQuizzes(stats.getTotalQuizzes() + req.getTotalCount());
        stats.setCorrectQuizzes(stats.getCorrectQuizzes() + req.getCorrectCount());
        learningStatsRepo.save(stats);

        // 유저 경험치 및 티어 갱신
        User user = userRepo.findById(req.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));
        int newExp = user.getTotalExp() + req.getEarnedExp();
        user.setTotalExp(newExp);

        UserTier newTier = tierRepo.findAll().stream()
                .filter(t -> newExp >= t.getMinExp() && newExp <= t.getMaxExp())
                .findFirst()
                .orElse(user.getTier());
        user.setTier(newTier);
        userRepo.save(user);

        // 응답 DTO 반환
        return QuizResultResponseDTO.builder()
                .resultMessage("결과 저장 및 티어 갱신 완료")
                .totalExp(user.getTotalExp())
                .currentTier(newTier.getTierName().name())
                .build();
    }
}
