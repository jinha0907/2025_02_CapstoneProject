package com.team06.hanq.controller;

import com.team06.hanq.config.ApiResponseDocs;
import com.team06.hanq.dto.*;
import com.team06.hanq.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "User Authentication", description = "유저 인증 API (로그인 / 회원가입)")
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "유저 회원 가입")
    @ApiResponse(responseCode = "200", description = "회원 가입 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @PostMapping("/signup")
    public UserResponseDTO signup(@RequestBody SignUpRequestDTO request) {
        return authService.signup(request);
    }

    @Operation(summary = "유저 로그인", description = "로그인 시 계정 정보를 전부 return합니다.")
    @ApiResponse(responseCode = "200", description = "회원 가입 성공")
    @ApiResponseDocs.DefaultErrorResponses
    @PostMapping("/login")
    public UserResponseDTO login(@RequestBody LoginRequestDTO request) {
        return authService.login(request);
    }
}
