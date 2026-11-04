--liquibase formatted sql

--changeset gdailly:006-sync-history-volumes
--comment: Volumes listed for each series of a synchronisation, as items under the series item (new, unchanged, removed).
ALTER TABLE sync_run_item ADD COLUMN parent_id BIGINT NULL AFTER run_id;
ALTER TABLE sync_run_item ADD COLUMN child_count INT NOT NULL DEFAULT 0;
ALTER TABLE sync_run_item ADD CONSTRAINT fk_sync_run_item_parent FOREIGN KEY (parent_id) REFERENCES sync_run_item (id) ON DELETE CASCADE;
ALTER TABLE sync_run_item DROP CONSTRAINT ck_sync_run_item_outcome;
ALTER TABLE sync_run_item ADD CONSTRAINT ck_sync_run_item_outcome CHECK (outcome IN ('UPDATED', 'UNCHANGED', 'FOUND',
    'NOT_FOUND', 'NO_REFERENCE', 'FAILED', 'ADDED', 'REMOVED'));
--rollback ALTER TABLE sync_run_item DROP CONSTRAINT ck_sync_run_item_outcome;
--rollback DELETE FROM sync_run_item WHERE parent_id IS NOT NULL;
--rollback ALTER TABLE sync_run_item ADD CONSTRAINT ck_sync_run_item_outcome CHECK (outcome IN ('UPDATED', 'UNCHANGED', 'FOUND', 'NOT_FOUND', 'NO_REFERENCE', 'FAILED'));
--rollback ALTER TABLE sync_run_item DROP FOREIGN KEY fk_sync_run_item_parent;
--rollback ALTER TABLE sync_run_item DROP COLUMN child_count;
--rollback ALTER TABLE sync_run_item DROP COLUMN parent_id;
