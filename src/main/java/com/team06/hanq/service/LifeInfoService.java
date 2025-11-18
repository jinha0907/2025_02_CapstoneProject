package com.team06.hanq.service;

import com.team06.hanq.dto.LifeInformationDTO;
import com.team06.hanq.entity.LifeInformation;
import com.team06.hanq.repository.LifeInformationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LifeInformationService {

    private final LifeInformationRepository repository;

    // 1️⃣ 전체 타이틀 조회
    public List<String> getAllTitles() {
        return repository.findAll().stream()
                .map(LifeInformation::getTitle)
                .distinct()
                .collect(Collectors.toList());
    }

    // 2️⃣ 특정 타이틀의 서브타이틀 조회
    public List<LifeInformationDTO> getSubtitlesByTitle(String title) {
        return repository.findByTitle(title).stream()
                .map(info -> LifeInformationDTO.builder()
                        .infoId(info.getInfoId())
                        .title(info.getTitle())
                        .subtitle(info.getSubtitle())
                        .build())
                .collect(Collectors.toList());
    }

    // 3️⃣ 상세 조회
    public LifeInformationDTO getLifeInfoDetail(Long infoId) {
        LifeInformation info = repository.findById(infoId)
                .orElseThrow(() -> new IllegalArgumentException("해당 정보가 존재하지 않습니다."));

        return LifeInformationDTO.builder()
                .infoId(info.getInfoId())
                .title(info.getTitle())
                .subtitle(info.getSubtitle())
                .explanation(info.getExplanation())
                .build();
    }
}

