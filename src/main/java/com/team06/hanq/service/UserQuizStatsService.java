package com.team06.hanq.service;

import com.team06.hanq.entity.LearningStats;
import com.team06.hanq.repository.LearningStatsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserQuizStatsService {

    private final LearningStatsRepository learningStatsRepo;

    // ✅ ① 유저 총 푼 문제 개수
    public int getTotalSolvedQuizzes(Long userId) {
        List<LearningStats> stats = learningStatsRepo.findAll()
                .stream()
                .filter(s -> s.getUserId().equals(userId))
                .collect(Collectors.toList());

        return stats.stream()
                .mapToInt(LearningStats::getTotalQuizzes)
                .sum();
    }

    // ✅ ② 최근 7일간 학습 현황
    public List<Map<String, Object>> getWeeklyStats(Long userId) {
        LocalDate sevenDaysAgo = LocalDate.now().minusDays(6);
        List<LearningStats> statsList =
                learningStatsRepo.findStatsForLast7Days(userId, sevenDaysAgo);

        List<Map<String, Object>> weeklyList = new ArrayList<>();

        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            int count = statsList.stream()
                    .filter(s -> s.getDate().equals(date))
                    .mapToInt(LearningStats::getTotalQuizzes)
                    .sum();

            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("date", date.toString());
            entry.put("count", count);
            weeklyList.add(entry);
        }

        return weeklyList;
    }

}
