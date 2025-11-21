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
}
