package com.team06.hanq.repository;

import com.team06.hanq.entity.QuizSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QuizSessionRepository extends JpaRepository<QuizSession, Long> {

    // 유저의 최근 세션 기록 (최신 순)
    @Query("SELECT s FROM QuizSession s WHERE s.userId = :userId ORDER BY s.finishedAt DESC")
    List<QuizSession> findRecentSessions(@Param("userId") Long userId);

    // 유저의 특정 퀴즈 기록
    @Query("SELECT s FROM QuizSession s WHERE s.userId = :userId AND s.quizId = :quizId")
    List<QuizSession> findByUserIdAndQuizId(@Param("userId") Long userId, @Param("quizId") Long quizId);

    List<QuizSession> findByUserId(Long userId);

    int countByUserIdAndQuizId(Long userId, Long quizId);
}
