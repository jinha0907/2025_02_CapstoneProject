package com.team06.hanq.repository;

import com.team06.hanq.entity.QuizHeader;
import com.team06.hanq.entity.QuizHeader.Difficulty;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuizHeaderRepository extends JpaRepository<QuizHeader, Long> {

    List<QuizHeader> findByCategory(String category);

    List<QuizHeader> findByDifficulty(Difficulty difficulty);
}
