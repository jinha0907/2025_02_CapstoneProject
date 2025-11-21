package com.team06.hanq.repository;

import com.team06.hanq.entity.UserQuiz;
import com.team06.hanq.entity.UserQuizId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UserQuizRepository extends JpaRepository<UserQuiz, UserQuizId> {

    // 유저가 푼 문제 목록
    @Query("SELECT uq.quizId FROM UserQuiz uq WHERE uq.userId = :userId")
    List<Long> findQuizIdsByUserId(@Param("userId") Long userId);
}
