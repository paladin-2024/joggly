package com.joggly.backend.security;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.security.GeneralSecurityException;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;

/**
 * Verifies the ID token a Flutter client obtains from Google Sign-In, so the backend never has
 * to trust a client-supplied email/name directly.
 */
@Component
public class GoogleTokenVerifier {

    private final GoogleIdTokenVerifier verifier;

    public GoogleTokenVerifier(@Value("${joggly.google.client-ids}") List<String> clientIds) {
        this.verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                .setAudience(clientIds)
                .build();
    }

    public GoogleIdToken.Payload verify(String idTokenString) {
        try {
            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken == null) {
                throw new BadCredentialsException("Invalid Google ID token");
            }
            GoogleIdToken.Payload payload = idToken.getPayload();
            if (!Boolean.TRUE.equals(payload.getEmailVerified())) {
                throw new BadCredentialsException("Google account email is not verified");
            }
            return payload;
        } catch (GeneralSecurityException | java.io.IOException e) {
            throw new BadCredentialsException("Could not verify Google ID token", e);
        } catch (IllegalArgumentException e) {
            // Thrown by Google's own JWT parser when idTokenString isn't even shaped like a
            // JWT (e.g. empty, garbage, or a non-JWT string) - a malformed token, not a server
            // error, so it maps to the same 401 as any other failed verification.
            throw new BadCredentialsException("Malformed Google ID token", e);
        }
    }
}
