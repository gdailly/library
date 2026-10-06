package com.gdailly.library.storage;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import javax.imageio.ImageIO;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import com.gdailly.library.config.LivreProperties;

class CoverStoreTest {

    @TempDir
    Path directory;

    private CoverStore store() {
        return new CoverStore(new LivreProperties(null, null, null, null,
                new LivreProperties.Covers(directory, "unused-secret-0123", null, null)));
    }

    @Test
    void storesOriginalAndThumbnailsFittingTheirBoxes() throws IOException {
        CoverStore store = store();
        String key = store.store(png(2000, 3000));

        assertThat(key).matches("[0-9a-f]{64}");
        assertThat(size(store, key, CoverStore.Variant.THUMB)).isEqualTo(new int[] {160, 240});
        assertThat(size(store, key, CoverStore.Variant.MEDIUM)).isEqualTo(new int[] {480, 720});
        assertThat(size(store, key, CoverStore.Variant.ORIGINAL)).isEqualTo(new int[] {800, 1200});
        assertThat(store.find(key, CoverStore.Variant.ORIGINAL).orElseThrow().getParent().getFileName().toString())
                .isEqualTo(key.substring(0, 2));
    }

    @Test
    void keepsWideImagesWithinWidth() throws IOException {
        CoverStore store = store();
        String key = store.store(png(1000, 500));
        assertThat(size(store, key, CoverStore.Variant.THUMB)).isEqualTo(new int[] {160, 80});
    }

    @Test
    void neverEnlargesSmallImages() throws IOException {
        CoverStore store = store();
        String key = store.store(png(128, 192));
        assertThat(size(store, key, CoverStore.Variant.THUMB)).isEqualTo(new int[] {128, 192});
        assertThat(size(store, key, CoverStore.Variant.MEDIUM)).isEqualTo(new int[] {128, 192});
    }

    @Test
    void storesIdenticalImagesOnce() throws IOException {
        CoverStore store = store();
        byte[] image = png(300, 450);
        String key = store.store(image);
        Path thumb = store.find(key, CoverStore.Variant.THUMB).orElseThrow();
        long written = Files.getLastModifiedTime(thumb).toMillis();
        Files.setLastModifiedTime(thumb, java.nio.file.attribute.FileTime.fromMillis(written - 60_000));

        assertThat(store.store(image)).isEqualTo(key);
        assertThat(Files.getLastModifiedTime(thumb).toMillis()).isEqualTo(written - 60_000);
        assertThat(store.store(png(301, 450))).isNotEqualTo(key);
    }

    @Test
    void flattensTransparencyOnWhite() throws IOException {
        CoverStore store = store();
        String key = store.store(png(100, 150));
        BufferedImage original = ImageIO.read(store.find(key, CoverStore.Variant.ORIGINAL).orElseThrow().toFile());
        Color bottom = new Color(original.getRGB(50, 140));
        assertThat(bottom.getRed()).isGreaterThan(240);
        assertThat(bottom.getGreen()).isGreaterThan(240);
    }

    @Test
    void refusesWhatIsNotAnImage() {
        assertThatThrownBy(() -> store().store("pas une image".getBytes())).isInstanceOf(IllegalArgumentException.class);
        assertThat(directory.toFile().list()).isEmpty();
    }

    @Test
    void findsOnlyWellFormedExistingKeys() throws IOException {
        CoverStore store = store();
        String key = store.store(png(100, 150));

        assertThat(store.find(key, CoverStore.Variant.THUMB)).isPresent();
        assertThat(store.find("f".repeat(64), CoverStore.Variant.THUMB)).isEmpty();
        assertThat(store.find("../../etc/passwd", CoverStore.Variant.THUMB)).isEmpty();
        assertThat(store.find(key.toUpperCase(), CoverStore.Variant.THUMB)).isEmpty();
        assertThat(store.find(null, CoverStore.Variant.THUMB)).isEmpty();
    }

    @Test
    void servesWebpThumbnailsAndJpegOriginal() {
        assertThat(CoverStore.Variant.THUMB.contentType()).isEqualTo("image/webp");
        assertThat(CoverStore.Variant.MEDIUM.contentType()).isEqualTo("image/webp");
        assertThat(CoverStore.Variant.ORIGINAL.contentType()).isEqualTo("image/jpeg");
    }

    private static int[] size(CoverStore store, String key, CoverStore.Variant variant) throws IOException {
        BufferedImage image = ImageIO.read(store.find(key, variant).orElseThrow().toFile());
        return new int[] {image.getWidth(), image.getHeight()};
    }

    /** Opaque green top half, transparent bottom half. */
    private static byte[] png(int width, int height) throws IOException {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = image.createGraphics();
        g.setColor(new Color(31, 94, 75));
        g.fillRect(0, 0, width, height / 2);
        g.dispose();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(image, "png", out);
        return out.toByteArray();
    }
}
