--liquibase formatted sql

--changeset gdailly:005-sync-history
--comment: History of the synchronisations (metadata of the books, volumes of the series) and of each item they processed, kept 30 days.
CREATE TABLE sync_run (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    kind         VARCHAR(30)  NOT NULL,
    library_id   BIGINT       NULL,
    started_by   VARCHAR(320) NULL,
    state        VARCHAR(20)  NOT NULL,
    total        INT          NOT NULL,
    processed    INT          NOT NULL DEFAULT 0,
    succeeded    INT          NOT NULL DEFAULT 0,
    unchanged    INT          NOT NULL DEFAULT 0,
    not_found    INT          NOT NULL DEFAULT 0,
    failed       INT          NOT NULL DEFAULT 0,
    started_at   DATETIME(6)  NOT NULL,
    finished_at  DATETIME(6)  NULL,
    CONSTRAINT pk_sync_run PRIMARY KEY (id),
    CONSTRAINT ck_sync_run_kind CHECK (kind IN ('METADATA_FILL', 'METADATA_FETCH', 'METADATA_BOOK', 'SERIES_ALL',
        'SERIES_SCHEDULED', 'SERIES_ONE')),
    CONSTRAINT ck_sync_run_state CHECK (state IN ('RUNNING', 'DONE', 'INTERRUPTED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE INDEX ix_sync_run_started_at ON sync_run (started_at);
CREATE TABLE sync_run_item (
    id         BIGINT        NOT NULL AUTO_INCREMENT,
    run_id     BIGINT        NOT NULL,
    label      VARCHAR(500)  NOT NULL,
    outcome    VARCHAR(20)   NOT NULL,
    detail     VARCHAR(1000) NULL,
    created_at DATETIME(6)   NOT NULL,
    CONSTRAINT pk_sync_run_item PRIMARY KEY (id),
    CONSTRAINT fk_sync_run_item_run FOREIGN KEY (run_id) REFERENCES sync_run (id) ON DELETE CASCADE,
    CONSTRAINT ck_sync_run_item_outcome CHECK (outcome IN ('UPDATED', 'UNCHANGED', 'FOUND', 'NOT_FOUND',
        'NO_REFERENCE', 'FAILED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE sync_run_item;
--rollback DROP TABLE sync_run;
