package com.gdailly.library.exception;

public class NotFoundException extends RuntimeException {

    public NotFoundException() {
        super("Not found");
    }
}
