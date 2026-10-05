package com.gdailly.library;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.jayway.jsonpath.JsonPath;

/** Full application against a MariaDB container; requests are authenticated with mock Google ID tokens. */
@SpringBootTest(properties = {
        "livre.bootstrap.owner-email=" + IntegrationTest.OWNER_EMAIL,
        "livre.covers.url-secret=integration-test-secret"})
@AutoConfigureMockMvc
@Import(TestcontainersConfiguration.class)
public abstract class IntegrationTest {

    protected static final String OWNER_EMAIL = "owner@example.com";

    protected static final FakeMetadataServer METADATA = FakeMetadataServer.INSTANCE;

    @DynamicPropertySource
    static void externalApis(DynamicPropertyRegistry registry) {
        registry.add("livre.isbn.open-library-url", METADATA::url);
        registry.add("livre.isbn.google-books-url", METADATA::url);
        registry.add("livre.covers.directory", () -> COVERS_DIRECTORY.toString());
    }

    private static final Path COVERS_DIRECTORY = createCoversDirectory();

    private static Path createCoversDirectory() {
        try {
            return Files.createTempDirectory("library-covers");
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    /** A {@code width}×{@code height} PNG with transparency. */
    protected static byte[] png(int width, int height) throws IOException {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = image.createGraphics();
        g.setColor(new Color(31, 94, 75, 200));
        g.fillRect(0, 0, width, height / 2);
        g.dispose();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(image, "png", out);
        return out.toByteArray();
    }

    @Autowired
    protected MockMvc mvc;

    @Autowired
    private AppUserRepository users;

    @Autowired
    private LibraryMemberRepository members;

    protected static JwtRequestPostProcessor googleUser(String email) {
        return jwt().jwt(token -> token
                .claim("iss", "https://accounts.google.com")
                .claim("email", email)
                .claim("email_verified", true)
                .claim("name", "Test " + email)
                .claim("picture", "https://example.com/" + email + ".png"));
    }

    protected static JwtRequestPostProcessor owner() {
        return googleUser(OWNER_EMAIL);
    }

    /** Adds {@code email} as a MEMBER of the owner's library (idempotent) and returns its token. */
    protected JwtRequestPostProcessor member(String email) {
        if (users.findByEmailIgnoreCase(email).isEmpty()) {
            Long libraryId = members.findByUserIdOrderByLibraryId(
                    users.findByEmailIgnoreCase(OWNER_EMAIL).orElseThrow().getId()).getFirst().getLibraryId();
            AppUser user = users.save(new AppUser(email));
            members.save(new LibraryMember(libraryId, user.getId(), Role.MEMBER));
        }
        return googleUser(email);
    }

    /** Creates a book as the owner and returns its id. */
    protected long createBook(String json) throws Exception {
        String body = mvc.perform(post("/api/books").with(owner()).contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(body, "$.id")).longValue();
    }
}
