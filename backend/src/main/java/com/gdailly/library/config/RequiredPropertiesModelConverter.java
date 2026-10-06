package com.gdailly.library.config;

import java.lang.reflect.RecordComponent;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;

import org.jspecify.annotations.Nullable;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.JavaType;

import io.swagger.v3.core.converter.AnnotatedType;
import io.swagger.v3.core.converter.ModelConverter;
import io.swagger.v3.core.converter.ModelConverterContext;
import io.swagger.v3.core.util.Json;
import io.swagger.v3.oas.models.media.Schema;

/**
 * Declares every component of our API records as required in the OpenAPI contract, except those typed
 * {@link Nullable}: the generated Dart client then gets non-nullable fields wherever the API guarantees a value.
 */
@Component
class RequiredPropertiesModelConverter implements ModelConverter {

    private static final String DTO_PACKAGE = "com.gdailly.library.dto";

    @Override
    @SuppressWarnings("rawtypes")
    public Schema resolve(AnnotatedType type, ModelConverterContext context, Iterator<ModelConverter> chain) {
        Schema schema = chain.hasNext() ? chain.next().resolve(type, context, chain) : null;
        Class<?> raw = rawClass(type);
        if (raw == null || !raw.isRecord() || !raw.getPackageName().equals(DTO_PACKAGE)) {
            return schema;
        }
        Schema target = schema;
        if (schema != null && schema.get$ref() != null) {
            target = context.getDefinedModels().get(schema.get$ref().substring(schema.get$ref().lastIndexOf('/') + 1));
        }
        if (target != null && target.getProperties() != null) {
            Map<?, ?> properties = target.getProperties();
            for (String name : Arrays.stream(raw.getRecordComponents())
                    .filter(component -> !component.getAnnotatedType().isAnnotationPresent(Nullable.class))
                    .map(RecordComponent::getName)
                    .filter(properties::containsKey)
                    .toList()) {
                if (target.getRequired() == null || !target.getRequired().contains(name)) {
                    target.addRequiredItem(name);
                }
            }
        }
        return schema;
    }

    private static Class<?> rawClass(AnnotatedType type) {
        if (type.getType() instanceof Class<?> c) {
            return c;
        }
        JavaType javaType = Json.mapper().constructType(type.getType());
        return javaType == null ? null : javaType.getRawClass();
    }
}
