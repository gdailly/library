package com.gdailly.library.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.request;

import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

import com.gdailly.library.IntegrationTest;

/**
 * Every API route declared in the application, discovered at runtime, must refuse a request without token (401)
 * and a Google account that is not a member (403). A new route is covered without touching this test.
 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class EndpointSecurityIT extends IntegrationTest {

    /** Routes authorised by other means than the token; each one is tested in its own class. */
    private static final Set<String> PUBLIC_ROUTES = Set.of(
            "GET /api/books/{id}/cover"); // signed URL, see CoverIT

    @Autowired
    @Qualifier("requestMappingHandlerMapping")
    private RequestMappingHandlerMapping handlerMapping;

    record Route(HttpMethod method, String pattern) {

        @Override
        public String toString() {
            return method + " " + pattern;
        }

        /** Path variables set to 1; a JSON body so that write routes reach security, not body parsing. */
        MockHttpServletRequestBuilder build() {
            String path = pattern.replaceAll("\\{[^}]+}", "1");
            return request(method, path).contentType(MediaType.APPLICATION_JSON).content("{}");
        }
    }

    Stream<Route> protectedRoutes() {
        return apiRoutes().stream().filter(route -> !PUBLIC_ROUTES.contains(route.toString()));
    }

    @Test
    void discoversTheWholeApi() {
        List<Route> routes = apiRoutes();
        assertThat(routes).hasSizeGreaterThanOrEqualTo(18);
        assertThat(routes.stream().map(Route::toString)).containsAll(PUBLIC_ROUTES);
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("protectedRoutes")
    void refusesRequestWithoutToken(Route route) throws Exception {
        assertThat(mvc.perform(route.build()).andReturn().getResponse().getStatus()).isEqualTo(401);
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("protectedRoutes")
    void refusesGoogleAccountThatIsNotMember(Route route) throws Exception {
        JwtRequestPostProcessor stranger = googleUser("stranger@example.com");
        assertThat(mvc.perform(route.build().with(stranger)).andReturn().getResponse().getStatus()).isEqualTo(403);
    }

    private List<Route> apiRoutes() {
        return handlerMapping.getHandlerMethods().keySet().stream()
                .flatMap(info -> info.getPatternValues().stream()
                        .filter(pattern -> pattern.startsWith("/api/"))
                        .flatMap(pattern -> info.getMethodsCondition().getMethods().stream()
                                .map(method -> new Route(HttpMethod.valueOf(method.name()), pattern))))
                .sorted((a, b) -> a.toString().compareTo(b.toString()))
                .toList();
    }
}
