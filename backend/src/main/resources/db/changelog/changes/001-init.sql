--liquibase formatted sql

--changeset gdailly:001-app-user
CREATE TABLE app_user (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(320)  NOT NULL,
    name        VARCHAR(200),
    avatar_url  VARCHAR(1000),
    created_at  DATETIME(6)   NOT NULL,
    CONSTRAINT uk_app_user_email UNIQUE (email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE app_user;

--changeset gdailly:001-library
CREATE TABLE library (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(200) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE library;

--changeset gdailly:001-library-member
CREATE TABLE library_member (
    library_id  BIGINT      NOT NULL,
    user_id     BIGINT      NOT NULL,
    role        VARCHAR(10) NOT NULL,
    PRIMARY KEY (library_id, user_id),
    CONSTRAINT fk_member_library FOREIGN KEY (library_id) REFERENCES library (id) ON DELETE CASCADE,
    CONSTRAINT fk_member_user FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE,
    CONSTRAINT ck_member_role CHECK (role IN ('OWNER', 'MEMBER'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE library_member;

--changeset gdailly:001-book
CREATE TABLE book (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    library_id  BIGINT        NOT NULL,
    isbn13      CHAR(13),
    title       VARCHAR(500)  NOT NULL,
    subtitle    VARCHAR(500),
    authors     VARCHAR(1000),
    publisher   VARCHAR(300),
    year        INT,
    pages       INT,
    language    VARCHAR(10),
    cover_key   CHAR(64),
    summary     TEXT,
    owned       BOOLEAN       NOT NULL DEFAULT TRUE,
    added_by    BIGINT,
    created_at  DATETIME(6)   NOT NULL,
    CONSTRAINT uk_book_library_isbn UNIQUE (library_id, isbn13),
    CONSTRAINT fk_book_library FOREIGN KEY (library_id) REFERENCES library (id) ON DELETE CASCADE,
    CONSTRAINT fk_book_added_by FOREIGN KEY (added_by) REFERENCES app_user (id) ON DELETE SET NULL,
    INDEX ix_book_library_title (library_id, title)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE book;

--changeset gdailly:001-category
CREATE TABLE category (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    library_id  BIGINT       NOT NULL,
    name        VARCHAR(100) NOT NULL,
    color       CHAR(7)      NOT NULL,
    CONSTRAINT uk_category_library_name UNIQUE (library_id, name),
    CONSTRAINT fk_category_library FOREIGN KEY (library_id) REFERENCES library (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE category;

--changeset gdailly:001-book-category
CREATE TABLE book_category (
    book_id      BIGINT NOT NULL,
    category_id  BIGINT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_category_book FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_book_category_category FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE book_category;

--changeset gdailly:001-reading
CREATE TABLE reading (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    book_id      BIGINT      NOT NULL,
    user_id      BIGINT      NOT NULL,
    status       VARCHAR(10) NOT NULL,
    rating       TINYINT,
    review       TEXT,
    started_on   DATE,
    finished_on  DATE,
    CONSTRAINT uk_reading_book_user UNIQUE (book_id, user_id),
    CONSTRAINT fk_reading_book FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE,
    CONSTRAINT fk_reading_user FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE,
    CONSTRAINT ck_reading_status CHECK (status IN ('TO_READ', 'READING', 'READ', 'ABANDONED')),
    CONSTRAINT ck_reading_rating CHECK (rating IS NULL OR rating BETWEEN 1 AND 5)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE reading;

--changeset gdailly:001-isbn-lookup
CREATE TABLE isbn_lookup (
    isbn13      CHAR(13)    NOT NULL PRIMARY KEY,
    source      VARCHAR(20) NOT NULL,
    payload     JSON,
    cover_key   CHAR(64),
    fetched_at  DATETIME(6) NOT NULL,
    CONSTRAINT ck_isbn_lookup_source CHECK (source IN ('OPEN_LIBRARY', 'GOOGLE_BOOKS', 'NOT_FOUND'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
--rollback DROP TABLE isbn_lookup;
