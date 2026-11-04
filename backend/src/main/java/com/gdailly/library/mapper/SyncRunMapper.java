package com.gdailly.library.mapper;

import org.mapstruct.Mapper;

import com.gdailly.library.dto.SyncRunItemResponse;
import com.gdailly.library.dto.SyncRunResponse;
import com.gdailly.library.entity.SyncRun;
import com.gdailly.library.entity.SyncRunItem;

@Mapper(config = MappingConfig.class)
public interface SyncRunMapper {

    SyncRunResponse toResponse(SyncRun run);

    SyncRunItemResponse toResponse(SyncRunItem item);
}
