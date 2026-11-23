package com.joggly.backend.feed;

import com.joggly.backend.feed.dto.FeedItemResponse;
import com.joggly.backend.user.User;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/feed")
@RequiredArgsConstructor
public class FeedController {

    private final FeedService feedService;

    @GetMapping
    public List<FeedItemResponse> feed(@AuthenticationPrincipal User user) {
        return feedService.feed(user);
    }
}
