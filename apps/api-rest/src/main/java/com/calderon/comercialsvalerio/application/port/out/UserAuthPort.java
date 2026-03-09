package com.calderon.comercialsvalerio.application.port.out;

import java.util.Optional;

public interface UserAuthPort {
    Optional<AuthUser> findByUsername(String username);

    record AuthUser(Long id, String username, String passwordHash, String role) {
    }
}
