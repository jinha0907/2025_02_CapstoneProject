package com.team06.hanq.service;

import com.team06.hanq.dto.*;
import com.team06.hanq.entity.*;
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
            throw new IllegalArgumentException("이미 존재하는 이메일입니다.");
        }

        // 기본 티어: BRONZE
        UserTier defaultTier = tierRepo.findByTierName(UserTier.TierName.BRONZE)
                .orElseThrow(() -> new IllegalStateException("기본 티어(BRONZE)가 없습니다."));

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
                .orElseThrow(() -> new IllegalArgumentException("이메일이 존재하지 않습니다."));

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("비밀번호가 올바르지 않습니다.");
        }

        UserSettings settings = settingsRepo.findAll().stream()
                .filter(s -> s.getUser().getUserId().equals(user.getUserId()))
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("유저 설정 정보가 없습니다."));

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
