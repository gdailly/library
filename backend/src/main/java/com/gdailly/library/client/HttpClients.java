package com.gdailly.library.client;

import java.net.http.HttpClient;
import java.time.Duration;

import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

final class HttpClients {

    private static final String USER_AGENT = "Library/1.0 (bibliotheque personnelle)";

    private HttpClients() {
    }

    static RestClient restClient(String baseUrl, Duration timeout) {
        HttpClient client = HttpClient.newBuilder()
                .connectTimeout(timeout)
                .followRedirects(HttpClient.Redirect.NORMAL)
                .build();
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(client);
        factory.setReadTimeout(timeout);
        RestClient.Builder builder = RestClient.builder()
                .requestFactory(factory)
                .defaultHeader("User-Agent", USER_AGENT);
        if (baseUrl != null) {
            builder.baseUrl(baseUrl);
        }
        return builder.build();
    }
}
