package com.gdailly.library.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.gdailly.library.entity.LibraryMember;
import com.gdailly.library.entity.Role;

public interface LibraryMemberRepository extends JpaRepository<LibraryMember, LibraryMember.Key> {

    List<LibraryMember> findByUserIdOrderByLibraryId(Long userId);

    List<LibraryMember> findByLibraryId(Long libraryId);

    long countByLibraryIdAndRole(Long libraryId, Role role);
}
