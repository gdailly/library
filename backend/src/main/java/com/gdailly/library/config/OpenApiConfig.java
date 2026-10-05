package com.gdailly.library.config;

import org.springdoc.core.utils.SpringDocUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.gdailly.library.security.CurrentUser;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;

@Configuration
class OpenApiConfig {

    private static final String GOOGLE_ID_TOKEN = "googleIdToken";

    static {
        // Resolved from the request, not sent by clients.
        SpringDocUtils.getConfig().addRequestWrapperToIgnore(CurrentUser.class);
    }

    @Bean
    OpenAPI libraryOpenApi() {
        return new OpenAPI()
                .info(new Info().title("Library API").version("1"))
                .addServersItem(new Server().url("/"))
                .components(new Components().addSecuritySchemes(GOOGLE_ID_TOKEN, new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT")
                        .description("ID token Google")))
                .addSecurityItem(new SecurityRequirement().addList(GOOGLE_ID_TOKEN));
    }
}
