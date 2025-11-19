package com.team06.hanq.repository;

import com.team06.hanq.entity.LifeInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LifeInfoRepository extends JpaRepository<LifeInfo, Long> {

    // 전체 title 목록 중복 제거
    List<LifeInfo> findDistinctByTitleIsNotNull();

    // 특정 title에 해당하는 데이터
    List<LifeInfo> findByTitle(String title);
}

