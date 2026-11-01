--liquibase formatted sql

--changeset gdailly:002-isbn-lookup-bnf
--comment: The BnF catalogue joins the ISBN sources; payload now holds the raw answer of every source that knew the ISBN.
ALTER TABLE isbn_lookup DROP CONSTRAINT ck_isbn_lookup_source;
ALTER TABLE isbn_lookup
    ADD CONSTRAINT ck_isbn_lookup_source CHECK (source IN ('OPEN_LIBRARY', 'GOOGLE_BOOKS', 'BNF', 'NOT_FOUND'));
--rollback ALTER TABLE isbn_lookup DROP CONSTRAINT ck_isbn_lookup_source;
--rollback ALTER TABLE isbn_lookup ADD CONSTRAINT ck_isbn_lookup_source CHECK (source IN ('OPEN_LIBRARY', 'GOOGLE_BOOKS', 'NOT_FOUND'));
