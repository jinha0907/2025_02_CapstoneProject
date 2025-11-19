package com.team06.hanq.service;

import com.team06.hanq.dto.LifeInfoDTO;
import com.team06.hanq.entity.LifeInfo;
import com.team06.hanq.repository.LifeInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LifeInfoService {

    private final LifeInfoRepository repository;

    // 1️⃣ 전체 타이틀 조회
    public List<String> getAllTitles() {
        return repository.findAll().stream()
                .map(LifeInfo::getTitle)
                .distinct()
                .collect(Collectors.toList());
    }

    // 2️⃣ 특정 타이틀의 서브타이틀 조회
    public List<LifeInfoDTO> getSubtitlesByTitle(String title) {
        return repository.findByTitle(title).stream()
                .map(info -> LifeInfoDTO.builder()
                        .infoId(info.getInfoId())
                        .title(info.getTitle())
                        .subtitle(info.getSubtitle())
                        .build())
                .collect(Collectors.toList());
    }

    // 3️⃣ 상세 조회
    public LifeInfoDTO getLifeInfoDetail(Long infoId) {
        LifeInfo info = repository.findById(infoId)
                .orElseThrow(() -> new IllegalArgumentException("해당 정보가 존재하지 않습니다."));

        return LifeInfoDTO.builder()
                .infoId(info.getInfoId())
                .title(info.getTitle())
                .subtitle(info.getSubtitle())
                .explanation(info.getExplanation())
                .build();
    }
}

