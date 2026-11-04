--liquibase formatted sql

--changeset gdailly:007-normalise-books-series
--comment: Normal forms. book holds the book itself (the result of the ISBN lookup), shared by every library; library_book says which library owns or wishes it; series and book_series replace book.series, book.series_number, series_catalog and series_volume. The volumes the BnF lists become books linked to their series. Irreversible data migration.

-- Series: one per name, case, accents and spaces ignored (utf8mb4_unicode_ci); name_key is the normalised name.
CREATE TABLE series (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(300) NOT NULL,
    name_key    VARCHAR(300) NOT NULL,
    status      VARCHAR(20)  NULL,
    source_ref  VARCHAR(20)  NULL,
    fetched_at  DATETIME(6)  NULL,
    CONSTRAINT pk_series PRIMARY KEY (id),
    CONSTRAINT uk_series_name_key UNIQUE (name_key),
    CONSTRAINT ck_series_status CHECK (status IS NULL OR status IN ('FOUND', 'NOT_FOUND', 'NO_REFERENCE'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

INSERT INTO series (name, name_key)
SELECT MIN(spelling), name_key
FROM (SELECT TRIM(REGEXP_REPLACE(series, '[[:space:]]+', ' ')) AS spelling,
             LOWER(TRIM(REGEXP_REPLACE(REPLACE(series, '’', ''''), '[[:space:]]+', ' '))) AS name_key
      FROM book
      WHERE series IS NOT NULL AND TRIM(series) <> '') named
GROUP BY name_key;

UPDATE series s JOIN series_catalog c ON c.series_key = s.name_key
SET s.status = c.status, s.source_ref = c.source_ref, s.fetched_at = c.fetched_at;

-- One book per ISBN: the oldest row of each ISBN is kept, the others (same ISBN in another library) point to it.
CREATE TABLE book_canonical (
    old_id  BIGINT NOT NULL PRIMARY KEY,
    new_id  BIGINT NOT NULL
) ENGINE = InnoDB;
INSERT INTO book_canonical (old_id, new_id)
SELECT b.id, COALESCE(first.id, b.id)
FROM book b
LEFT JOIN (SELECT isbn13, MIN(id) AS id FROM book WHERE isbn13 IS NOT NULL GROUP BY isbn13) first
       ON first.isbn13 = b.isbn13;

-- What each library owns or wishes.
CREATE TABLE library_book (
    id          BIGINT      NOT NULL AUTO_INCREMENT,
    library_id  BIGINT      NOT NULL,
    book_id     BIGINT      NOT NULL,
    owned       BOOLEAN     NOT NULL DEFAULT TRUE,
    added_by    BIGINT      NULL,
    created_at  DATETIME(6) NOT NULL,
    CONSTRAINT pk_library_book PRIMARY KEY (id),
    CONSTRAINT uk_library_book UNIQUE (library_id, book_id),
    CONSTRAINT fk_library_book_library FOREIGN KEY (library_id) REFERENCES library (id) ON DELETE CASCADE,
    CONSTRAINT fk_library_book_book FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_library_book_added_by FOREIGN KEY (added_by) REFERENCES app_user (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
INSERT INTO library_book (id, library_id, book_id, owned, added_by, created_at)
SELECT b.id, b.library_id, c.new_id, b.owned, b.added_by, b.created_at
FROM book b JOIN book_canonical c ON c.old_id = b.id;

-- Categories belong to a library: they now tag what the library holds.
CREATE TABLE library_book_category (
    library_book_id  BIGINT NOT NULL,
    category_id      BIGINT NOT NULL,
    CONSTRAINT pk_library_book_category PRIMARY KEY (library_book_id, category_id),
    CONSTRAINT fk_library_book_category_library_book FOREIGN KEY (library_book_id) REFERENCES library_book (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_library_book_category_category FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- library_book.id kept the id of the book row it comes from.
INSERT INTO library_book_category (library_book_id, category_id)
SELECT book_id, category_id FROM book_category;
DROP TABLE book_category;

-- A member's reading of a duplicate goes to the kept book (a second reading of the same book is dropped with it).
UPDATE IGNORE reading r JOIN book_canonical c ON c.old_id = r.book_id
SET r.book_id = c.new_id
WHERE c.old_id <> c.new_id;

-- Series of each book, with its volume number.
CREATE TABLE book_series (
    book_id    BIGINT NOT NULL,
    series_id  BIGINT NOT NULL,
    number     INT    NULL,
    CONSTRAINT pk_book_series PRIMARY KEY (book_id, series_id),
    CONSTRAINT fk_book_series_book FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_book_series_series FOREIGN KEY (series_id) REFERENCES series (id) ON DELETE CASCADE,
    INDEX ix_book_series_series (series_id, number)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
INSERT IGNORE INTO book_series (book_id, series_id, number)
SELECT c.new_id, s.id, b.series_number
FROM book b
JOIN book_canonical c ON c.old_id = b.id
JOIN series s ON s.name_key = LOWER(TRIM(REGEXP_REPLACE(REPLACE(b.series, '’', ''''), '[[:space:]]+', ' ')))
WHERE b.series IS NOT NULL AND TRIM(b.series) <> '';

-- The duplicates go; book keeps only what describes the book itself.
DELETE b FROM book b JOIN book_canonical c ON c.old_id = b.id WHERE c.old_id <> c.new_id;
DROP TABLE book_canonical;
ALTER TABLE book DROP FOREIGN KEY fk_book_library;
ALTER TABLE book DROP FOREIGN KEY fk_book_added_by;
ALTER TABLE book DROP INDEX uk_book_library_isbn;
ALTER TABLE book DROP INDEX ix_book_library_title;
ALTER TABLE book DROP INDEX ix_book_library_series;
ALTER TABLE book
    DROP COLUMN library_id,
    DROP COLUMN series,
    DROP COLUMN series_number,
    DROP COLUMN owned,
    DROP COLUMN added_by;
ALTER TABLE book ADD CONSTRAINT uk_book_isbn13 UNIQUE (isbn13);
CREATE INDEX ix_book_title ON book (title);

-- The volumes the BnF listed become books (or link the book that already has their ISBN), unless the series already
-- has a book of that number.
ALTER TABLE book ADD COLUMN tmp_series_id BIGINT NULL, ADD COLUMN tmp_number INT NULL;
INSERT IGNORE INTO book_series (book_id, series_id, number)
SELECT b.id, s.id, v.number
FROM series_volume v
JOIN series s ON s.name_key = v.series_key
JOIN book b ON b.isbn13 = v.isbn13
WHERE NOT EXISTS (SELECT 1 FROM book_series l WHERE l.series_id = s.id AND l.number = v.number);
INSERT IGNORE INTO book (isbn13, title, year, created_at, tmp_series_id, tmp_number)
SELECT v.isbn13, v.title, v.year, NOW(6), s.id, v.number
FROM series_volume v
JOIN series s ON s.name_key = v.series_key
WHERE NOT EXISTS (SELECT 1 FROM book_series l WHERE l.series_id = s.id AND l.number = v.number)
  AND (v.isbn13 IS NULL OR NOT EXISTS (SELECT 1 FROM book o WHERE o.isbn13 = v.isbn13));
INSERT INTO book_series (book_id, series_id, number)
SELECT id, tmp_series_id, tmp_number FROM book WHERE tmp_series_id IS NOT NULL;
ALTER TABLE book DROP COLUMN tmp_series_id, DROP COLUMN tmp_number;
DROP TABLE series_volume;
DROP TABLE series_catalog;
