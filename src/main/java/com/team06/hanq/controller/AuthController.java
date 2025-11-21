package com.team06.hanq.controller;

import com.team06.hanq.dto.*;
import com.team06.hanq.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public UserResponseDTO signup(@RequestBody SignUpRequestDTO request) {
        return authService.signup(request);
    }

    @PostMapping("/login")
    public UserResponseDTO login(@RequestBody LoginRequestDTO request) {
        return authService.login(request);
    }
}
