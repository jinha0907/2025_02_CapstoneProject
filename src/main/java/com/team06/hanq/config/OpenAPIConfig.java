package com.team06.hanq.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.media.Schema;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenAPIConfig {

    @Bean
    public OpenAPI customOpenAPI() {

        ObjectSchema errorResponseSchema = new ObjectSchema();
        errorResponseSchema.addProperty("code", new Schema<>().type("string").example("USER_NOT_FOUND"));
        errorResponseSchema.addProperty("message", new Schema<>().type("string").example("해당 유저를 찾을 수 없습니다."));
        errorResponseSchema.addProperty("status", new Schema<>().type("integer").example(404));
        errorResponseSchema.addProperty("timestamp", new Schema<>().type("string").example("2025-11-28T18:50:31.245"));

        Components components = new Components().addSchemas("ErrorResponse", errorResponseSchema);

        return new OpenAPI()
                .components(components)
                .info(new Info()
                        .title("HANQ API")
                        .version("v1.0.0")
                        .description("한국 문화 학습 및 퀴즈 서비스 백엔드 API 명세서"));
    }
}
