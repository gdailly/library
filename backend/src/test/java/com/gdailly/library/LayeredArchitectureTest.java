package com.gdailly.library;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.library.Architectures.layeredArchitecture;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

import jakarta.persistence.Entity;

/** Keeps the package-per-layer structure: controller → business → repository → entity. */
@AnalyzeClasses(packages = "com.gdailly.library", importOptions = ImportOption.DoNotIncludeTests.class)
class LayeredArchitectureTest {

    private static final String ROOT = "com.gdailly.library.";

    @ArchTest
    static final ArchRule layers = layeredArchitecture().consideringOnlyDependenciesInLayers()
            .layer("Controller").definedBy(ROOT + "controller..")
            .layer("Business").definedBy(ROOT + "business..")
            .layer("Repository").definedBy(ROOT + "repository..")
            .layer("Entity").definedBy(ROOT + "entity..")
            .layer("Dto").definedBy(ROOT + "dto..")
            .layer("Mapper").definedBy(ROOT + "mapper..")
            .layer("Client").definedBy(ROOT + "client..")
            .layer("Storage").definedBy(ROOT + "storage..")
            .layer("Security").definedBy(ROOT + "security..")
            .layer("Config").definedBy(ROOT + "config..")
            .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
            .whereLayer("Business").mayOnlyBeAccessedByLayers("Controller", "Security", "Config")
            .whereLayer("Repository").mayOnlyBeAccessedByLayers("Business")
            .whereLayer("Mapper").mayOnlyBeAccessedByLayers("Business")
            .whereLayer("Client").mayOnlyBeAccessedByLayers("Business", "Mapper")
            .whereLayer("Storage").mayOnlyBeAccessedByLayers("Business")
            // Controllers may use the entity enums (ReadingStatus as a query parameter), never JPA entities: see below.
            .whereLayer("Entity").mayOnlyBeAccessedByLayers("Controller", "Repository", "Business", "Mapper", "Dto", "Security")
            .whereLayer("Dto").mayOnlyBeAccessedByLayers("Controller", "Business", "Mapper");

    @ArchTest
    static final ArchRule controllersDoNotUseEntities = noClasses()
            .that().resideInAPackage(ROOT + "controller..")
            .should().dependOnClassesThat().areAnnotatedWith(Entity.class);
}
