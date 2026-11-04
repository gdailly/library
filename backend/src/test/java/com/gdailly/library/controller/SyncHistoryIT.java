package com.gdailly.library.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import com.gdailly.library.IntegrationTest;
import com.gdailly.library.business.SyncHistoryService;
import com.gdailly.library.entity.SyncItemOutcome;
import com.gdailly.library.entity.SyncKind;
import com.gdailly.library.repository.SyncRunRepository;
import com.jayway.jsonpath.JsonPath;

class SyncHistoryIT extends IntegrationTest {

    @Autowired
    private SyncHistoryService history;

    @Autowired
    private SyncRunRepository runs;

    @Autowired
    private JdbcTemplate jdbc;

    @Test
    void recordsEachBookOfAFullResynchronisation() throws Exception {
        String isbn = "9780000091024";
        createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"Historique\"}");
        METADATA.googleBooksKnows(isbn, "{\"title\": \"Historique\", \"description\": \"Résumé.\"}");

        String started = mvc.perform(post("/api/admin/metadata/sync").with(owner()))
                .andExpect(status().isAccepted())
                .andReturn().getResponse().getContentAsString();
        int total = JsonPath.read(started, "$.total");

        long runId = 0;
        for (int i = 0; i < 100; i++) {
            String body = mvc.perform(get("/api/admin/syncs").with(owner()))
                    .andExpect(status().isOk())
                    .andReturn().getResponse().getContentAsString();
            runId = ((Number) JsonPath.read(body, "$.items[0].id")).longValue();
            if ("DONE".equals(JsonPath.read(body, "$.items[0].state"))) {
                break;
            }
            Thread.sleep(100);
        }
        mvc.perform(get("/api/admin/syncs/{id}", runId).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.kind").value("METADATA_FILL"))
                .andExpect(jsonPath("$.state").value("DONE"))
                .andExpect(jsonPath("$.startedBy").value("owner@example.com"))
                .andExpect(jsonPath("$.processed").value(total));
        mvc.perform(get("/api/admin/syncs/{id}/items", runId).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalItems").value(total))
                .andExpect(jsonPath("$.items[?(@.label == 'Historique')].outcome").value("UPDATED"))
                .andExpect(jsonPath("$.items[?(@.label == 'Historique')].detail").value("Modifié : résumé"));
    }

    @Test
    void listsOnlyTheProblemsWhenAsked() throws Exception {
        Long runId = history.start(SyncKind.SERIES_ALL, null, "owner@example.com", 2);
        history.record(runId, "Astérix", SyncItemOutcome.FOUND, "2 tomes listés", List.of(
                new SyncHistoryService.Child("Tome 1 · Astérix le Gaulois", SyncItemOutcome.UNCHANGED, "possédé"),
                new SyncHistoryService.Child("Tome 2 · La Serpe d'or", SyncItemOutcome.ADDED, null)));
        history.record(runId, "Inconnue", SyncItemOutcome.NO_REFERENCE, null);

        mvc.perform(get("/api/admin/syncs/{id}", runId).with(owner()))
                .andExpect(jsonPath("$.state").value("RUNNING"))
                .andExpect(jsonPath("$.succeeded").value(1))
                .andExpect(jsonPath("$.notFound").value(1));
        mvc.perform(get("/api/admin/syncs/{id}/items", runId).param("problemsOnly", "true").with(owner()))
                .andExpect(jsonPath("$.items.length()").value(1))
                .andExpect(jsonPath("$.items[0].label").value("Inconnue"));
        String all = mvc.perform(get("/api/admin/syncs/{id}/items", runId).with(owner()))
                .andExpect(jsonPath("$.totalItems").value(2))
                .andExpect(jsonPath("$.items[1].label").value("Astérix"))
                .andExpect(jsonPath("$.items[1].childCount").value(2))
                .andReturn().getResponse().getContentAsString();
        long seriesItem = ((Number) JsonPath.read(all, "$.items[1].id")).longValue();
        mvc.perform(get("/api/admin/syncs/{id}/items/{itemId}/children", runId, seriesItem).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].label").value("Tome 1 · Astérix le Gaulois"))
                .andExpect(jsonPath("$[1].outcome").value("ADDED"));
        history.finish(runId, false);
    }

    @Test
    void purgesTheFinishedRunsOlderThan30Days() {
        Long old = history.start(SyncKind.SERIES_SCHEDULED, null, null, 1);
        history.record(old, "Ancienne", SyncItemOutcome.FOUND, "1 tome listé");
        history.finish(old, false);
        Long recent = history.start(SyncKind.SERIES_SCHEDULED, null, null, 0);
        history.finish(recent, false);
        jdbc.update("update sync_run set started_at = ? where id = ?", Instant.now().minus(Duration.ofDays(31)), old);

        assertThat(history.purge()).isGreaterThanOrEqualTo(1);

        assertThat(runs.findById(old)).isEmpty();
        assertThat(runs.findById(recent)).isPresent();
        assertThat(jdbc.queryForObject("select count(*) from sync_run_item where run_id = ?", Integer.class, old))
                .isZero();
    }

    @Test
    void isReservedToTheAdministrator() throws Exception {
        var member = member("frank@example.com");
        mvc.perform(get("/api/admin/syncs").with(member)).andExpect(status().isForbidden());
        mvc.perform(get("/api/admin/syncs/1/items").with(member)).andExpect(status().isForbidden());
    }
}
