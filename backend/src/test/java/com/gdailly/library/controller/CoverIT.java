package com.gdailly.library.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;

import javax.imageio.ImageIO;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockMultipartFile;

import com.gdailly.library.IntegrationTest;
import com.jayway.jsonpath.JsonPath;

class CoverIT extends IntegrationTest {

    @Test
    void uploadsAndServesThumbnailsThroughSignedUrls() throws Exception {
        long id = createBook("{\"title\": \"Couverture envoyée\"}");
        String body = upload(id, png(1600, 2400)).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        String thumbUrl = JsonPath.read(body, "$.thumbUrl");
        String mediumUrl = JsonPath.read(body, "$.mediumUrl");

        // No token: the signature is the authorisation.
        MockHttpServletResponse thumb = mvc.perform(get(thumbUrl))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "image/webp"))
                .andExpect(header().string("Cache-Control", "max-age=86400, private"))
                .andReturn().getResponse();
        BufferedImage thumbImage = ImageIO.read(new ByteArrayInputStream(thumb.getContentAsByteArray()));
        assertThat(thumbImage.getWidth()).isEqualTo(160);
        assertThat(thumbImage.getHeight()).isEqualTo(240);

        BufferedImage medium = ImageIO.read(new ByteArrayInputStream(
                mvc.perform(get(mediumUrl)).andExpect(status().isOk()).andReturn().getResponse().getContentAsByteArray()));
        assertThat(medium.getWidth()).isEqualTo(480);

        mvc.perform(get(thumbUrl).header("If-None-Match", thumb.getHeader("ETag"))).andExpect(status().isNotModified());
        mvc.perform(get("/api/books/{id}", id).with(owner()))
                .andExpect(jsonPath("$.cover.thumbUrl").value(thumbUrl));
    }

    @Test
    void refusesTamperedOrForeignUrls() throws Exception {
        long id = createBook("{\"title\": \"Lien falsifié\"}");
        String thumbUrl = JsonPath.read(upload(id, png(200, 300)).andReturn().getResponse().getContentAsString(), "$.thumbUrl");

        mvc.perform(get(thumbUrl.replace("sig=", "sig=x"))).andExpect(status().isForbidden());
        mvc.perform(get(thumbUrl.replace("/books/" + id + "/", "/books/" + (id + 1) + "/"))).andExpect(status().isForbidden());
        mvc.perform(get(thumbUrl.replaceFirst("expires=\\d+", "expires=1"))).andExpect(status().isForbidden());
    }

    @Test
    void rejectsNonImagesAndRemovesCover() throws Exception {
        long id = createBook("{\"title\": \"Pas une image\"}");
        upload(id, "bonjour".getBytes()).andExpect(status().isBadRequest());

        upload(id, png(100, 150)).andExpect(status().isOk());
        mvc.perform(delete("/api/books/{id}/cover", id).with(owner())).andExpect(status().isNoContent());
        mvc.perform(get("/api/books/{id}", id).with(owner())).andExpect(jsonPath("$.cover").doesNotExist());
    }

    @Test
    void downloadsLookupCoverOnceWhenBookIsAdded() throws Exception {
        String isbn = "9780000000064";
        String imageUrl = METADATA.serveImage("lookup-cover.png", png(300, 450));
        METADATA.openLibraryKnows(isbn, "{\"title\": \"Avec couverture\", \"cover\": {\"large\": \"" + imageUrl + "\"}}");

        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner())).andExpect(status().isOk());
        long id = createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"Avec couverture\"}");

        String thumbUrl = JsonPath.read(mvc.perform(get("/api/books/{id}", id).with(owner()))
                .andReturn().getResponse().getContentAsString(), "$.cover.thumbUrl");
        mvc.perform(get(thumbUrl)).andExpect(status().isOk());
        assertThat(METADATA.calls("lookup-cover.png")).isEqualTo(1);

        // Removed then re-added: the cover comes from the cache, not from a new download.
        mvc.perform(delete("/api/books/{id}", id).with(owner())).andExpect(status().isNoContent());
        createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"Avec couverture\"}");
        assertThat(METADATA.calls("lookup-cover.png")).isEqualTo(1);
    }

    @Test
    void addsBookEvenWhenCoverDownloadFails() throws Exception {
        String isbn = "9780000000071";
        METADATA.openLibraryKnows(isbn, "{\"title\": \"Couverture perdue\", \"cover\": {\"large\": \"" + METADATA.url() + "/images/missing.png\"}}");
        mvc.perform(get("/api/lookup/isbn/{isbn}", isbn).with(owner())).andExpect(status().isOk());

        long id = createBook("{\"isbn\": \"" + isbn + "\", \"title\": \"Couverture perdue\"}");
        mvc.perform(get("/api/books/{id}", id).with(owner())).andExpect(jsonPath("$.cover").doesNotExist());
    }

    private org.springframework.test.web.servlet.ResultActions upload(long bookId, byte[] content) throws Exception {
        return mvc.perform(multipart(HttpMethod.PUT, "/api/books/{id}/cover", bookId)
                .file(new MockMultipartFile("file", "cover.png", "image/png", content))
                .with(owner()));
    }
}
