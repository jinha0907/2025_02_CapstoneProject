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

    // 전체 푼 문제 개수
    @Query("SELECT COUNT(qs) FROM QuizSession qs WHERE qs.userId = :userId")
    long countTotalAttempts(@Param("userId") Long userId);

    // 맞힌 문제 개수
    @Query("SELECT COUNT(qs) FROM QuizSession qs WHERE qs.userId = :userId AND qs.isCorrect = true")
    long countCorrectAttempts(@Param("userId") Long userId);

    @Query("""
    SELECT h.category AS category, COUNT(qs.quizId) AS solvedCount
    FROM QuizSession qs
    JOIN QuizHeader h ON qs.quizId = h.quizId
    WHERE qs.userId = :userId
    GROUP BY h.category
""")
    List<Object[]> countSolvedByCategory(@Param("userId") Long userId);

    @Query("""
    SELECT h.category AS category, COUNT(qs.quizId) AS count
    FROM QuizSession qs
    JOIN QuizHeader h ON qs.quizId = h.quizId
    WHERE qs.userId = :userId AND qs.isCorrect = true
    GROUP BY h.category
    ORDER BY count DESC
""")
    List<Object[]> countCorrectByCategory(@Param("userId") Long userId);

    @Query("""
    SELECT h.category AS category, COUNT(qs.quizId) AS count
    FROM QuizSession qs
    JOIN QuizHeader h ON qs.quizId = h.quizId
    WHERE qs.userId = :userId AND qs.isCorrect = false
    GROUP BY h.category
    ORDER BY count DESC
""")
    List<Object[]> countWrongByCategory(@Param("userId") Long userId);

}
