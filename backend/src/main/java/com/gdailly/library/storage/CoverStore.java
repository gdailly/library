package com.gdailly.library.storage;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.HexFormat;
import java.util.Optional;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

import org.springframework.stereotype.Component;

import com.gdailly.library.config.LivreProperties;

import net.coobird.thumbnailator.Thumbnails;

/**
 * Cover files on disk, named by the SHA-256 of the received image ({@code cover_key}):
 * {@code <dir>/<2 first chars>/<key>-original.jpg}, {@code -medium.webp} and {@code -thumb.webp}.
 * Identical images are stored once.
 */
@Component
public class CoverStore {

    public enum Variant {
        THUMB(160, 240, "webp"),
        MEDIUM(480, 720, "webp"),
        ORIGINAL(1200, 1200, "jpg");

        private final int maxWidth;
        private final int maxHeight;
        private final String extension;

        Variant(int maxWidth, int maxHeight, String extension) {
            this.maxWidth = maxWidth;
            this.maxHeight = maxHeight;
            this.extension = extension;
        }

        public String contentType() {
            return "webp".equals(extension) ? "image/webp" : "image/jpeg";
        }
    }

    private static final float WEBP_QUALITY = 0.8f;
    private static final float JPEG_QUALITY = 0.9f;

    private final Path directory;

    CoverStore(LivreProperties properties) {
        this.directory = properties.covers().directory();
        // Register plugins from the application class loader (Spring Boot jar), then fail fast if WebP is missing.
        ImageIO.scanForPlugins();
        if (!ImageIO.getImageWritersByFormatName("webp").hasNext()) {
            throw new IllegalStateException("No WebP ImageIO writer: check the webp-imageio dependency and native access");
        }
    }

    /**
     * Stores an image and its variants; returns its key.
     *
     * @throws IllegalArgumentException when the bytes are not an image ImageIO can read
     */
    public String store(byte[] image) {
        String key = sha256(image);
        if (Arrays.stream(Variant.values()).allMatch(v -> Files.exists(path(key, v)))) {
            return key;
        }
        BufferedImage source = read(image);
        try {
            Files.createDirectories(path(key, Variant.ORIGINAL).getParent());
            for (Variant variant : Variant.values()) {
                write(fit(source, variant), variant, path(key, variant));
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        return key;
    }

    public Optional<Path> find(String key, Variant variant) {
        if (key == null || !key.matches("[0-9a-f]{64}")) {
            return Optional.empty();
        }
        Path path = path(key, variant);
        return Files.isRegularFile(path) ? Optional.of(path) : Optional.empty();
    }

    private Path path(String key, Variant variant) {
        return directory.resolve(key.substring(0, 2)).resolve(key + "-" + variant.name().toLowerCase() + "." + variant.extension);
    }

    private static BufferedImage read(byte[] image) {
        try {
            BufferedImage decoded = ImageIO.read(new ByteArrayInputStream(image));
            if (decoded == null) {
                throw new IllegalArgumentException("Unsupported image format");
            }
            // JPEG and lossy WebP have no alpha channel worth keeping: flatten on white.
            BufferedImage rgb = new BufferedImage(decoded.getWidth(), decoded.getHeight(), BufferedImage.TYPE_INT_RGB);
            Graphics2D g = rgb.createGraphics();
            g.drawImage(decoded, 0, 0, Color.WHITE, null);
            g.dispose();
            return rgb;
        } catch (IOException e) {
            throw new IllegalArgumentException("Unreadable image", e);
        }
    }

    /** Shrinks to fit the variant's box, keeping the aspect ratio; never enlarges. */
    private static BufferedImage fit(BufferedImage source, Variant variant) throws IOException {
        if (source.getWidth() <= variant.maxWidth && source.getHeight() <= variant.maxHeight) {
            return source;
        }
        return Thumbnails.of(source).size(variant.maxWidth, variant.maxHeight).asBufferedImage();
    }

    private static void write(BufferedImage image, Variant variant, Path target) throws IOException {
        Path temp = Files.createTempFile(target.getParent(), "cover", ".tmp");
        try {
            ImageWriter writer = ImageIO.getImageWritersByFormatName(variant.extension).next();
            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            if ("webp".equals(variant.extension)) {
                param.setCompressionType(Arrays.stream(param.getCompressionTypes())
                        .filter(t -> t.equalsIgnoreCase("lossy")).findFirst().orElse(param.getCompressionTypes()[0]));
            }
            param.setCompressionQuality("webp".equals(variant.extension) ? WEBP_QUALITY : JPEG_QUALITY);
            try (OutputStream out = Files.newOutputStream(temp); ImageOutputStream ios = ImageIO.createImageOutputStream(out)) {
                writer.setOutput(ios);
                writer.write(null, new IIOImage(image, null, null), param);
            } finally {
                writer.dispose();
            }
            Files.move(temp, target, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
        } finally {
            Files.deleteIfExists(temp);
        }
    }

    private static String sha256(byte[] content) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(content));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
