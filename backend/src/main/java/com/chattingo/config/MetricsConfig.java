package com.chattingo.config;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MetricsConfig {

    @Bean
    public Counter messagesSentCounter(MeterRegistry meterRegistry) {
        return Counter.builder("chattingo_messages_sent_total")
                .description("Total number of messages sent")
                .register(meterRegistry);
    }

    @Bean
    public Counter userRegistrationsCounter(MeterRegistry meterRegistry) {
        return Counter.builder("chattingo_user_registrations_total")
                .description("Total number of user registrations")
                .register(meterRegistry);
    }

    @Bean
    public Counter userLoginsCounter(MeterRegistry meterRegistry) {
        return Counter.builder("chattingo_user_logins_total")
                .description("Total number of user logins")
                .register(meterRegistry);
    }

    @Bean
    public Timer messageProcessingTimer(MeterRegistry meterRegistry) {
        return Timer.builder("chattingo_message_processing_duration")
                .description("Time taken to process messages")
                .register(meterRegistry);
    }
}
