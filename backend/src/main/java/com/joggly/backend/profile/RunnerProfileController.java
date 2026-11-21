package com.joggly.backend.profile;

import com.joggly.backend.profile.dto.NearbyRunnerResponse;
import com.joggly.backend.profile.dto.ProfileResponse;
import com.joggly.backend.profile.dto.UpdateLocationRequest;
import com.joggly.backend.profile.dto.UpdateProfileRequest;
import com.joggly.backend.user.User;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/profiles")
@RequiredArgsConstructor
public class RunnerProfileController {

    private final RunnerProfileService profileService;

    @GetMapping("/me")
    public ProfileResponse me(@AuthenticationPrincipal User user) {
        return profileService.getOrCreate(user);
    }

    @PutMapping("/me")
    public ProfileResponse update(
            @AuthenticationPrincipal User user, @Valid @RequestBody UpdateProfileRequest request) {
        return profileService.update(user, request);
    }

    @PutMapping("/me/location")
    public ProfileResponse updateLocation(
            @AuthenticationPrincipal User user, @Valid @RequestBody UpdateLocationRequest request) {
        return profileService.updateLocation(user, request);
    }

    @GetMapping("/nearby")
    public List<NearbyRunnerResponse> nearby(
            @AuthenticationPrincipal User user,
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "5.0") double radiusKm) {
        return profileService.findNearby(user, lat, lng, radiusKm);
    }
}
