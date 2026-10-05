package com.gdailly.library.security;

import java.io.IOException;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.filter.OncePerRequestFilter;

import com.gdailly.library.business.MembershipService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/** Rejects with 403 any authenticated Google account that is not a member of a library. */
public class MembershipFilter extends OncePerRequestFilter {

    private static final String FORBIDDEN_BODY =
            "{\"status\":403,\"title\":\"Forbidden\",\"detail\":\"Ce compte n'est membre d'aucune bibliothèque.\"}";

    private final MembershipService membershipService;

    public MembershipFilter(MembershipService membershipService) {
        this.membershipService = membershipService;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith(request.getContextPath() + "/api/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication instanceof JwtAuthenticationToken token)) {
            chain.doFilter(request, response);
            return;
        }
        Jwt jwt = token.getToken();
        Optional<CurrentUser> member = membershipService.resolve(
                jwt.getClaimAsString("email"), jwt.getClaimAsString("name"), jwt.getClaimAsString("picture"));
        if (member.isEmpty()) {
            response.setStatus(HttpStatus.FORBIDDEN.value());
            response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(FORBIDDEN_BODY);
            return;
        }
        request.setAttribute(CurrentUser.ATTRIBUTE, member.get());
        chain.doFilter(request, response);
    }
}
