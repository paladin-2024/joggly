-- Baseline schema, hand-written to match the JPA entities exactly (Hibernate runs in
-- ddl-auto=validate, not update, so this file is now the only thing that changes the schema).

CREATE TABLE users (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    email VARCHAR(255) NOT NULL,
    google_id VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_google_id UNIQUE (google_id)
);

CREATE TABLE runner_profiles (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    user_id UUID NOT NULL,
    bio VARCHAR(500),
    avatar_url VARCHAR(255),
    pace_min_per_km DOUBLE PRECISION,
    preferred_distance_km DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_updated_at TIMESTAMPTZ,
    discoverable BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_runner_profiles_user UNIQUE (user_id),
    CONSTRAINT fk_runner_profiles_user FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Backs the "nearby runners" bounding-box query (RunnerProfileRepository).
CREATE INDEX idx_runner_profiles_location ON runner_profiles (latitude, longitude) WHERE discoverable = TRUE;

CREATE TABLE run_events (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    host_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    start_time TIMESTAMPTZ NOT NULL,
    start_latitude DOUBLE PRECISION NOT NULL,
    start_longitude DOUBLE PRECISION NOT NULL,
    start_address VARCHAR(255),
    distance_km DOUBLE PRECISION,
    pace_min_per_km DOUBLE PRECISION,
    max_participants INTEGER NOT NULL,
    status VARCHAR(255) NOT NULL,
    CONSTRAINT fk_run_events_host FOREIGN KEY (host_id) REFERENCES users (id)
);

-- Backs the "nearby runs" bounding-box query (RunEventRepository).
CREATE INDEX idx_run_events_location ON run_events (start_latitude, start_longitude) WHERE status = 'SCHEDULED';
CREATE INDEX idx_run_events_host ON run_events (host_id);

CREATE TABLE run_participants (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    run_event_id UUID NOT NULL,
    user_id UUID NOT NULL,
    status VARCHAR(255) NOT NULL,
    CONSTRAINT uq_run_participants_run_user UNIQUE (run_event_id, user_id),
    CONSTRAINT fk_run_participants_run FOREIGN KEY (run_event_id) REFERENCES run_events (id),
    CONSTRAINT fk_run_participants_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_run_participants_run_status ON run_participants (run_event_id, status);

CREATE TABLE connections (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    requester_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    status VARCHAR(255) NOT NULL,
    CONSTRAINT fk_connections_requester FOREIGN KEY (requester_id) REFERENCES users (id),
    CONSTRAINT fk_connections_recipient FOREIGN KEY (recipient_id) REFERENCES users (id),
    CONSTRAINT chk_connections_not_self CHECK (requester_id <> recipient_id)
);

-- One connection per pair of people regardless of who sent the request first (A->B and B->A
-- are the same pair), so two near-simultaneous requests can't create two rows.
CREATE UNIQUE INDEX uq_connections_pair
    ON connections (LEAST(requester_id, recipient_id), GREATEST(requester_id, recipient_id));
