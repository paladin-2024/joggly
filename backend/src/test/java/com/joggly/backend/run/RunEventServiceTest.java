package com.joggly.backend.run;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.joggly.backend.common.exception.ConflictException;
import com.joggly.backend.user.User;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Covers the capacity check in join(): the one piece of logic this app can't afford to get
 * wrong, since it's what stops a run from being overbooked (see RunEventRepository#findByIdForUpdate).
 */
@ExtendWith(MockitoExtension.class)
class RunEventServiceTest {

    @Mock
    private RunEventRepository runEventRepository;

    @Mock
    private RunParticipantRepository participantRepository;

    private RunEventService service;

    private RunEvent run;
    private User joiningUser;

    @BeforeEach
    void setUp() {
        service = new RunEventService(runEventRepository, participantRepository);

        User host = User.builder().email("host@example.com").googleId("g-host").displayName("Host").build();
        run = RunEvent.builder()
                .host(host)
                .title("Sunday long run")
                .startTime(Instant.now().plusSeconds(3600))
                .startLatitude(0.0)
                .startLongitude(0.0)
                .maxParticipants(2)
                .status(RunStatus.SCHEDULED)
                .build();

        joiningUser = User.builder().email("joiner@example.com").googleId("g-joiner").displayName("Joiner").build();
    }

    @Test
    void join_rejectsWithConflict_whenRunIsAlreadyFull() {
        when(runEventRepository.findByIdForUpdate(any(UUID.class))).thenReturn(Optional.of(run));
        when(participantRepository.findByRunEventIdAndUserId(any(), any())).thenReturn(Optional.empty());
        when(participantRepository.countByRunEventIdAndStatus(any(), eq(ParticipantStatus.JOINED)))
                .thenReturn(2L);

        assertThatThrownBy(() -> service.join(UUID.randomUUID(), joiningUser))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("full");

        verify(participantRepository, never()).save(any());
    }

    @Test
    void join_locksTheRunRow_insteadOfAPlainLookup() {
        UUID runId = UUID.randomUUID();
        when(runEventRepository.findByIdForUpdate(runId)).thenReturn(Optional.of(run));
        when(participantRepository.findByRunEventIdAndUserId(any(), any())).thenReturn(Optional.empty());
        when(participantRepository.countByRunEventIdAndStatus(any(), eq(ParticipantStatus.JOINED)))
                .thenReturn(0L);

        service.join(runId, joiningUser);

        verify(runEventRepository).findByIdForUpdate(runId);
        verify(runEventRepository, never()).findById(any());
    }

    @Test
    void join_succeeds_whenASpotIsFree() {
        RunParticipant savedParticipant =
                RunParticipant.builder().runEvent(run).user(joiningUser).status(ParticipantStatus.JOINED).build();

        when(runEventRepository.findByIdForUpdate(any(UUID.class))).thenReturn(Optional.of(run));
        // First call (inside join(), before saving) finds no prior participation; the second
        // call (inside toResponse(), after saving) reflects the row we just wrote.
        when(participantRepository.findByRunEventIdAndUserId(any(), any()))
                .thenReturn(Optional.empty(), Optional.of(savedParticipant));
        when(participantRepository.countByRunEventIdAndStatus(any(), eq(ParticipantStatus.JOINED)))
                .thenReturn(1L);

        var response = service.join(UUID.randomUUID(), joiningUser);

        assertThat(response.currentUserJoined()).isTrue();
        verify(participantRepository).save(any());
    }
}
