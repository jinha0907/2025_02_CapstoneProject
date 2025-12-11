package com.team06.hanq.service;

import com.team06.hanq.dto.QuizResultItemDTO;
import com.team06.hanq.dto.QuizResultRequestDTO;
import com.team06.hanq.dto.QuizResultResponseDTO;
import com.team06.hanq.entity.*;
import com.team06.hanq.exception.CustomException;
import com.team06.hanq.exception.ErrorCode;
import com.team06.hanq.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.team06.hanq.dto.UserAccuracyDTO;
import com.team06.hanq.dto.CategoryStatsDTO;
import com.team06.hanq.dto.CategoryStatsDTO.CategoryCount;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizDetailsRepository quizDetailsRepo;
    private final UserSettingsRepository settingsRepo;
    private final QuizSessionRepository quizSessionRepo;
    private final LearningStatsRepository learningStatsRepo;
    private final UserRepository userRepo;
    private final UserTierRepository tierRepo;

    // 사용자에게 오늘의 퀴즈 불러오기
    public List<QuizDetails> getQuizForUser(Long userId) {
        // 사용자 설정 불러오기
        UserSettings settings = settingsRepo.findByUser_UserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTINGS_NOT_FOUND));

        int questionCount = settings.getQuestionCount();
        int reviewCount = (questionCount <= 5) ? 1 : 2;
        int newCount = questionCount - reviewCount;
        String userDifficulty = settings.getDifficulty().name();

        // 유저가 틀린 문제 목록 가져오기
        List<Long> wrongQuizIds = quizSessionRepo.findByUserId(userId).stream()
                .filter(session -> !session.isCorrect())
                .map(QuizSession::getQuizId)
                .distinct()
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
            reviewQuizzes.addAll(quizDetailsRepo.findRandomQuizzesByDifficulty(userDifficulty, reviewCount));
        }

        // 새 문제 추출
        List<QuizDetails> newQuizzes = quizDetailsRepo.findRandomQuizzesByDifficulty(userDifficulty, newCount);

        // 문제 통합
        List<QuizDetails> finalList = new ArrayList<>();
        finalList.addAll(reviewQuizzes);
        finalList.addAll(newQuizzes);
        Collections.shuffle(finalList);

        return finalList;
    }

    public QuizResultResponseDTO saveQuizResult(QuizResultRequestDTO req) {
        int correctCount = 0;

        // quiz_session 저장
        for(QuizResultItemDTO qri : req.getResults()) {
            boolean isCorrect = qri.isCorrect();
            if (isCorrect) correctCount++;

            // 기존 시도 횟수 확인
            int attemptCount = quizSessionRepo.countByUserIdAndQuizId(req.getUserId(), qri.getQuizId()) + 1;
            QuizSession session = QuizSession.builder()
                    .userId(req.getUserId())
                    .quizId(qri.getQuizId())
                    .isCorrect(isCorrect)
                    .attemptCount(attemptCount)
                    .score(req.getScore())
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
        stats.setCorrectQuizzes(stats.getCorrectQuizzes() + correctCount);
        learningStatsRepo.save(stats);

        // 유저 경험치 및 티어 갱신
        User user = userRepo.findById(req.getUserId())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
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

    public UserAccuracyDTO getUserAccuracy(Long userId) {
        long totalAttempts = quizSessionRepo.countTotalAttempts(userId);
        long correctAttempts = quizSessionRepo.countCorrectAttempts(userId);

        double accuracy = (totalAttempts == 0)
                ? 0.0
                : Math.round(((double) correctAttempts / totalAttempts) * 1000.0) / 1000.0;

        return UserAccuracyDTO.builder()
                .userId(userId)
                .totalQuizzes((int) totalAttempts)
                .correctQuizzes((int) correctAttempts)
                .accuracy(accuracy)
                .build();
    }

    public CategoryStatsDTO getSolvedByCategory(Long userId) {
        // 1️⃣ DB에서 유저가 푼 문제의 카테고리별 개수 조회
        List<Object[]> results = quizSessionRepo.countSolvedByCategory(userId);

        // 2️⃣ DB에 존재하는 전체 카테고리 가져오기
        List<String> allCategories = quizDetailsRepo.findAll().stream()
                .map(q -> q.getQuizHeader().getCategory())
                .distinct()
                .toList();

        // 3️⃣ map으로 변환
        Map<String, Long> solvedMap = results.stream()
                .collect(Collectors.toMap(
                        r -> (String) r[0],
                        r -> (Long) r[1]
                ));

        // 4️⃣ 전체 카테고리를 기준으로, 푼 게 없으면 0
        List<CategoryCount> categoryList = allCategories.stream()
                .map(cat -> CategoryCount.builder()
                        .category(cat)
                        .solvedCount(solvedMap.getOrDefault(cat, 0L))
                        .build())
                .toList();

        return CategoryStatsDTO.builder()
                .userId(userId)
                .categories(categoryList)
                .build();
    }

}
