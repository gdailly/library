package com.gdailly.library;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

/** Stands in for Open Library and Google Books; answers are programmed per ISBN, calls are counted. */
public final class FakeMetadataServer {

    public static final FakeMetadataServer INSTANCE = new FakeMetadataServer();

    private static final Pattern ISBN = Pattern.compile("(\\d{13})");

    private final HttpServer server;
    private final Map<String, String> openLibrary = new ConcurrentHashMap<>();
    private final Map<String, String> googleBooks = new ConcurrentHashMap<>();
    private final Map<String, byte[]> images = new ConcurrentHashMap<>();
    private final Map<String, AtomicInteger> calls = new ConcurrentHashMap<>();
    private volatile boolean googleBooksDown;

    private FakeMetadataServer() {
        try {
            server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        server.createContext("/api/books", exchange -> answer(exchange, openLibrary, "{}", false));
        server.createContext("/books/v1/volumes", exchange -> answer(exchange, googleBooks, "{\"totalItems\": 0}", googleBooksDown));
        server.createContext("/images/", this::image);
        server.start();
    }

    /** Serves {@code bytes} at the returned URL and counts its downloads under {@code name}. */
    public String serveImage(String name, byte[] bytes) {
        images.put(name, bytes);
        return url() + "/images/" + name;
    }

    private void image(HttpExchange exchange) throws IOException {
        String name = exchange.getRequestURI().getPath().substring("/images/".length());
        calls.computeIfAbsent(name, k -> new AtomicInteger()).incrementAndGet();
        byte[] body = images.get(name);
        if (body == null) {
            exchange.sendResponseHeaders(404, -1);
        } else {
            exchange.getResponseHeaders().add("Content-Type", "image/png");
            exchange.sendResponseHeaders(200, body.length);
            exchange.getResponseBody().write(body);
        }
        exchange.close();
    }

    public String url() {
        return "http://127.0.0.1:" + server.getAddress().getPort();
    }

    public void openLibraryKnows(String isbn13, String bookJson) {
        openLibrary.put(isbn13, "{\"ISBN:" + isbn13 + "\": " + bookJson + "}");
    }

    public void googleBooksKnows(String isbn13, String volumeInfoJson) {
        googleBooks.put(isbn13, "{\"totalItems\": 1, \"items\": [{\"volumeInfo\": " + volumeInfoJson + "}]}");
    }

    public void googleBooksDown(boolean down) {
        googleBooksDown = down;
    }

    /** Number of requests, both APIs together, that mentioned this ISBN (or downloads of this image name). */
    public int calls(String isbn13) {
        return calls.getOrDefault(isbn13, new AtomicInteger()).get();
    }

    private void answer(HttpExchange exchange, Map<String, String> known, String empty, boolean down) throws IOException {
        Matcher matcher = ISBN.matcher(exchange.getRequestURI().getQuery());
        String isbn = matcher.find() ? matcher.group(1) : "";
        calls.computeIfAbsent(isbn, k -> new AtomicInteger()).incrementAndGet();
        byte[] body = (down ? "{}" : known.getOrDefault(isbn, empty)).getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(down ? 500 : 200, body.length);
        exchange.getResponseBody().write(body);
        exchange.close();
    }
}
