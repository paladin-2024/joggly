package com.joggly.backend.user.dto;

import jakarta.validation.constraints.NotBlank;

/** idToken is the Google ID token obtained on-device via Google Sign-In. */
public record GoogleAuthRequest(@NotBlank String idToken) {
}
