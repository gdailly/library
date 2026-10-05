package com.gdailly.library.business;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.entity.AppUser;
import com.gdailly.library.entity.Library;
import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;
import com.gdailly.library.repository.AppUserRepository;
import com.gdailly.library.repository.LibraryMemberRepository;
import com.gdailly.library.repository.LibraryRepository;

/** Creates the first library and its owner from {@code BOOTSTRAP_OWNER_EMAIL} when the database has none. */
@Component
class BootstrapOwner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(BootstrapOwner.class);
    private static final String DEFAULT_LIBRARY_NAME = "Ma bibliothèque";

    private final LivreProperties properties;
    private final LibraryRepository libraries;
    private final LibraryMemberRepository members;
    private final AppUserRepository users;

    BootstrapOwner(LivreProperties properties, LibraryRepository libraries, LibraryMemberRepository members, AppUserRepository users) {
        this.properties = properties;
        this.libraries = libraries;
        this.members = members;
        this.users = users;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        String email = properties.bootstrap().ownerEmail();
        if (email == null || email.isBlank() || libraries.count() > 0) {
            return;
        }
        String name = properties.bootstrap().libraryName();
        Library library = libraries.save(new Library(name == null || name.isBlank() ? DEFAULT_LIBRARY_NAME : name));
        AppUser owner = users.findByEmailIgnoreCase(email.trim()).orElseGet(() -> users.save(new AppUser(email.trim())));
        members.save(new LibraryMember(library.getId(), owner.getId(), Role.OWNER));
        log.info("Created library '{}' owned by {}", library.getName(), owner.getEmail());
    }
}
