package com.gdailly.library.client;

import java.util.Optional;

/** An external book metadata API queried by ISBN. */
public interface MetadataClient {

    /** Raw JSON answer, empty when the API does not know the ISBN. Throws on network or server errors. */
    Optional<String> fetch(String isbn13);

    /** Reads a raw answer previously returned by {@link #fetch}, fresh or from the cache. */
    Optional<BookMetadata> parse(String isbn13, String payload);
}
