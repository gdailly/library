package com.gdailly.library.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Background tasks (listing the volumes of the series, purging the synchronisation history); off with
 * {@code livre.scheduling-enabled=false}.
 */
@Configuration
@EnableScheduling
@ConditionalOnProperty(name = "livre.scheduling-enabled", havingValue = "true", matchIfMissing = true)
class SchedulingConfig {
}
