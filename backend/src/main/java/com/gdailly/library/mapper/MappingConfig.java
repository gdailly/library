package com.gdailly.library.mapper;

import org.mapstruct.InjectionStrategy;
import org.mapstruct.MapperConfig;
import org.mapstruct.MappingConstants;
import org.mapstruct.ReportingPolicy;

import com.gdailly.library.util.Strings;

/**
 * Shared MapStruct settings: Spring beans injected by constructor, and a build error for any target property
 * left unmapped. Every String copied by a mapper goes through {@link Strings#trimToNull(String)}.
 */
@MapperConfig(
        componentModel = MappingConstants.ComponentModel.SPRING,
        injectionStrategy = InjectionStrategy.CONSTRUCTOR,
        unmappedTargetPolicy = ReportingPolicy.ERROR,
        uses = Strings.class)
public interface MappingConfig {
}
