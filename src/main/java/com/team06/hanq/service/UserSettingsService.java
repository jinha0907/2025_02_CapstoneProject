package com.team06.hanq.service;

import com.team06.hanq.dto.UserSettingsRequestDTO;
import com.team06.hanq.dto.UserSettingsResponseDTO;
import com.team06.hanq.entity.UserSettings;
import com.team06.hanq.exception.CustomException;
import com.team06.hanq.exception.ErrorCode;
import com.team06.hanq.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserSettingsService {

    private final UserSettingsRepository settingsRepo;

    public UserSettingsResponseDTO getUserSettings(Long userId) {
        UserSettings settings = settingsRepo.findByUser_UserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        return UserSettingsResponseDTO.builder()
                .difficulty(settings.getDifficulty().name())
                .questionCount(settings.getQuestionCount())
                .build();
    }

    public UserSettingsResponseDTO updateDifficulty(Long userId, String newDifficulty) {
        UserSettings settings = settingsRepo.findByUser_UserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        settings.setDifficulty(UserSettings.Difficulty.valueOf(newDifficulty.toUpperCase()));
        settingsRepo.save(settings);

        return UserSettingsResponseDTO.builder()
                .difficulty(settings.getDifficulty().name())
                .questionCount(settings.getQuestionCount())
                .build();
    }

    public UserSettingsResponseDTO updateQuestionCount(Long userId, int count) {
        UserSettings settings = settingsRepo.findByUser_UserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        settings.setQuestionCount(count);
        settingsRepo.save(settings);

        return UserSettingsResponseDTO.builder()
                .difficulty(settings.getDifficulty().name())
                .questionCount(settings.getQuestionCount())
                .build();
    }
}

