package com.team06.hanq.service;

import com.team06.hanq.dto.*;
import com.team06.hanq.entity.*;
import com.team06.hanq.exception.CustomException;
import com.team06.hanq.exception.ErrorCode;
import com.team06.hanq.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepo;
    private final UserTierRepository tierRepo;
    private final UserSettingsRepository settingsRepo;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // 🟢 회원가입
    public UserResponseDTO signup(SignUpRequestDTO req) {
        if (userRepo.existsByEmail(req.getEmail())) {
            throw new CustomException(ErrorCode.EMAIL_DUPLICATE);
        }

        // 기본 티어: BRONZE
        UserTier defaultTier = tierRepo.findByTierName(UserTier.TierName.BRONZE)
                .orElseThrow(() -> new CustomException(ErrorCode.INFO_NOT_FOUND));

        User user = User.builder()
                .email(req.getEmail())
                .password(passwordEncoder.encode(req.getPassword()))
                .nickname(req.getNickname())
                .tier(defaultTier)
                .totalExp(0)
                .build();

        userRepo.save(user);

        // 기본 설정
        UserSettings settings = UserSettings.builder()
                .user(user)
                .difficulty(UserSettings.Difficulty.NORMAL)
                .questionCount(5)
                .build();
        settingsRepo.save(settings);

        return UserResponseDTO.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .nickname(user.getNickname())
                .tier(user.getTier().getTierName().name())
                .totalExp(user.getTotalExp())
                .difficulty(settings.getDifficulty().name())
                .questionCount(settings.getQuestionCount())
                .build();
    }

    // 🟡 로그인
    public UserResponseDTO login(LoginRequestDTO req) {
        User user = userRepo.findByEmail(req.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        UserSettings settings = settingsRepo.findAll().stream()
                .filter(s -> s.getUser().getUserId().equals(user.getUserId()))
                .findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.SETTINGS_NOT_FOUND));

        return UserResponseDTO.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .nickname(user.getNickname())
                .tier(user.getTier().getTierName().name())
                .totalExp(user.getTotalExp())
                .difficulty(settings.getDifficulty().name())
                .questionCount(settings.getQuestionCount())
                .build();
    }
}
