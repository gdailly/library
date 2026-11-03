package com.gdailly.library.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/** Background tasks (listing the volumes of the series); off with {@code livre.series.refresh-enabled=false}. */
@Configuration
@EnableScheduling
@ConditionalOnProperty(name = "livre.series.refresh-enabled", havingValue = "true", matchIfMissing = true)
class SchedulingConfig {
}
