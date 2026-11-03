--liquibase formatted sql

--changeset gdailly:004-series-catalog
--comment: Volumes of each series as listed by the BnF catalogue, fetched in the background, to show what is missing.
CREATE TABLE series_catalog (
    series_key  VARCHAR(300) NOT NULL,
    status      VARCHAR(20)  NOT NULL,
    source_ref  VARCHAR(20)  NULL,
    fetched_at  DATETIME(6) NOT NULL,
    CONSTRAINT pk_series_catalog PRIMARY KEY (series_key),
    CONSTRAINT ck_series_catalog_status CHECK (status IN ('FOUND', 'NOT_FOUND', 'NO_REFERENCE'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE series_volume (
    series_key  VARCHAR(300) NOT NULL,
    number      INT          NOT NULL,
    title       VARCHAR(500) NOT NULL,
    isbn13      CHAR(13)     NULL,
    year        INT          NULL,
    CONSTRAINT pk_series_volume PRIMARY KEY (series_key, number),
    CONSTRAINT fk_series_volume_catalog FOREIGN KEY (series_key) REFERENCES series_catalog (series_key) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE series_volume;
--rollback DROP TABLE series_catalog;
