package com.gdailly.library.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.gdailly.library.dto.ReadingRequest;
import com.gdailly.library.dto.OtherReadingResponse;
import com.gdailly.library.dto.ReadingResponse;
import com.gdailly.library.entity.Reading;

@Mapper(config = MappingConfig.class)
public interface ReadingMapper {

    /** Null when the user has no reading of the book yet. */
    ReadingResponse toResponse(Reading reading);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "bookId", ignore = true)
    @Mapping(target = "userId", ignore = true)
    void updateEntity(ReadingRequest request, @MappingTarget Reading reading);

    @Mapping(target = "userId", source = "reading.userId")
    @Mapping(target = "name", source = "name")
    OtherReadingResponse toOtherReading(Reading reading, String name);
}
