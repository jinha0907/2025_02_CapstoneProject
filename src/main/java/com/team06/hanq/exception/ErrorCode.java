package com.team06.hanq.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {

    // 공통
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다."),
    INVALID_REQUEST(HttpStatus.BAD_REQUEST, "요청 형식이 올바르지 않습니다."),

    // 사용자 관련
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 유저를 찾을 수 없습니다."),
    EMAIL_DUPLICATE(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다."),
    INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "비밀번호가 일치하지 않습니다."),

    // 퀴즈 관련
    QUIZ_NOT_FOUND(HttpStatus.NOT_FOUND, "요청한 퀴즈를 찾을 수 없습니다."),
    QUIZ_ALREADY_EXISTS(HttpStatus.CONFLICT, "이미 존재하는 퀴즈입니다."),

    // 설정 관련
    SETTINGS_NOT_FOUND(HttpStatus.NOT_FOUND, "유저 설정 정보를 찾을 수 없습니다."),

    // 정보 관련
    INFO_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 정보를 찾을 수 없습니다.");

    private final HttpStatus status;
    private final String message;

    ErrorCode(HttpStatus status, String message) {
        this.status = status;
        this.message = message;
    }
}
