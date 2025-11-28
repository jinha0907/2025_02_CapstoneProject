package com.team06.hanq.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        // ⚙️ ErrorResponse 모델을 Swagger에 등록
        Components components = new Components()
                .addSchemas("ErrorResponse", new ObjectSchema()
                        .addProperty("code", new Schema<String>().example("USER_NOT_FOUND"))
                        .addProperty("message", new Schema<String>().example("해당 유저를 찾을 수 없습니다."))
                        .addProperty("status", new Schema<Integer>().example(404))
                        .addProperty("timestamp", new Schema<String>().example("2025-11-28T18:50:31.245"))
                );

        return new OpenAPI()
                .info(new Info()
                        .title("HANQ API")
                        .version("v1.0")
                        .description("한국 문화 학습 및 퀴즈 서비스 백엔드 API"))
                .components(components);
    }
}
