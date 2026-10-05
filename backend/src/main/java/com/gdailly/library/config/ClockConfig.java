package com.gdailly.library.config;

import java.time.Clock;
import java.time.ZoneId;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class ClockConfig {

    /** Dates such as "finished today" follow the users' time zone, not the server's. */
    @Bean
    Clock clock(@Value("${livre.time-zone:Europe/Paris}") String timeZone) {
        return Clock.system(ZoneId.of(timeZone));
    }
}
