package com.team06.hanq.service;

import com.team06.hanq.entity.CultureInfo;
import com.team06.hanq.exception.CustomException;
import com.team06.hanq.exception.ErrorCode;
import com.team06.hanq.repository.CultureInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CultureInfoService {

    private final CultureInfoRepository repo;

    // 전체 title 목록
    public List<String> getAllTitles() {
        return repo.findAll().stream()
                .map(CultureInfo::getTitle)
                .distinct()
                .collect(Collectors.toList());
    }

    // 특정 title의 subtitle 목록
    public List<CultureInfo> getSubtitlesByTitle(String title) {
        return repo.findByTitle(title);
    }

    // 특정 subtitle의 subsubtitle 목록
    public List<CultureInfo> getSubsubtitlesBySubtitle(String subtitle) {
        return repo.findBySubtitle(subtitle);
    }


    // 특정 항목 상세 조회
    public CultureInfo getDetail(Long infoId) {
        return repo.findById(infoId)
                .orElseThrow(() -> new CustomException(ErrorCode.INFO_NOT_FOUND));
    }
}

