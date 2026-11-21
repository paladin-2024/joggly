package com.joggly.backend.user;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.joggly.backend.security.GoogleTokenVerifier;
import com.joggly.backend.security.JwtService;
import com.joggly.backend.user.dto.AuthResponse;
import com.joggly.backend.user.dto.GoogleAuthRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtService jwtService;

    @Transactional
    public AuthResponse loginWithGoogle(GoogleAuthRequest request) {
        GoogleIdToken.Payload payload = googleTokenVerifier.verify(request.idToken());

        String googleId = payload.getSubject();
        String email = payload.getEmail();
        String name = (String) payload.get("name");
        String picture = (String) payload.get("picture");

        User user = userRepository.findByGoogleId(googleId)
                .or(() -> userRepository.findByEmail(email))
                .map(existing -> {
                    existing.setEmail(email);
                    existing.setGoogleId(googleId);
                    if (name != null) existing.setDisplayName(name);
                    if (picture != null) existing.setAvatarUrl(picture);
                    return existing;
                })
                .orElseGet(() -> User.builder()
                        .email(email)
                        .googleId(googleId)
                        .displayName(name != null ? name : email)
                        .avatarUrl(picture)
                        .build());

        userRepository.save(user);

        String token = jwtService.generateToken(user);
        return new AuthResponse(token, user.getId(), user.getEmail(), user.getDisplayName());
    }
}
