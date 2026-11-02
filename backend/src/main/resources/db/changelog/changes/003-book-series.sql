--liquibase formatted sql

--changeset gdailly:003-book-series
--comment: A book can belong to a series (comics, sagas), with its volume number, to see what the library misses.
ALTER TABLE book
    ADD COLUMN series VARCHAR(300) NULL AFTER subtitle,
    ADD COLUMN series_number INT NULL AFTER series;
CREATE INDEX ix_book_library_series ON book (library_id, series);
--rollback DROP INDEX ix_book_library_series ON book;
--rollback ALTER TABLE book DROP COLUMN series_number, DROP COLUMN series;
