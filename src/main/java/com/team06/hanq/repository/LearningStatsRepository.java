package com.team06.hanq.repository;

import com.team06.hanq.entity.LearningStats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface LearningStatsRepository extends JpaRepository<LearningStats, Long> {

    Optional<LearningStats> findByUserIdAndDate(Long userId, LocalDate date);

    @Query("SELECT l FROM LearningStats l WHERE l.userId = :userId AND l.date >= :startDate ORDER BY l.date ASC")
    List<LearningStats> findStatsForLast7Days(@Param("userId") Long userId, @Param("startDate") LocalDate startDate);

    @Query(value = """
    SELECT ls.date AS day,
           ls.total_quizzes AS total,
           ls.correct_quizzes AS correct
    FROM learning_stats ls
    WHERE ls.user_id = :userId
      AND ls.date >= DATE_SUB(CURRENT_DATE, INTERVAL :days DAY)
    ORDER BY ls.date ASC
""", nativeQuery = true)
    List<Object[]> findAccuracyTrendFromStats(@Param("userId") Long userId, @Param("days") int days);

}
