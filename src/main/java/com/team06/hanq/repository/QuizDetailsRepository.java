package com.team06.hanq.repository;

import com.team06.hanq.entity.QuizDetails;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QuizDetailsRepository extends JpaRepository<QuizDetails, Long> {

    // 특정 퀴즈 헤더에 속한 문제 전체
    List<QuizDetails> findByQuizHeader_QuizId(Long quizId);

    // 랜덤 문제 N개 가져오기
    @Query(value = "SELECT * FROM quiz_details ORDER BY RAND() LIMIT :limit", nativeQuery = true)
    List<QuizDetails> findRandomQuizzes(@Param("limit") int limit);


    // 난이도 기반 랜덤 문제 조회
    @Query(value = """
    SELECT qd.* FROM quiz_details qd
    JOIN quiz_header qh ON qd.quiz_id = qh.quiz_id
    WHERE qh.difficulty = :difficulty
    ORDER BY RAND() LIMIT :limit
""", nativeQuery = true)
    List<QuizDetails> findRandomQuizzesByDifficulty(
            @Param("difficulty") String difficulty,
            @Param("limit") int limit);

    // 퀴즈 중복 내용 확인용
    boolean existsByQuestion(String question);



}
