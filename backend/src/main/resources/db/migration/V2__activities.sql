CREATE TABLE activities (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    user_id UUID NOT NULL,
    run_event_id UUID,
    start_time TIMESTAMPTZ NOT NULL,
    duration_seconds INTEGER NOT NULL,
    distance_km DOUBLE PRECISION NOT NULL,
    average_pace_min_per_km DOUBLE PRECISION NOT NULL,
    step_count INTEGER,
    route_points_json TEXT NOT NULL,
    CONSTRAINT fk_activities_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_activities_run_event FOREIGN KEY (run_event_id) REFERENCES run_events (id)
);

-- Backs "my activity history" (newest first) and the profile stats aggregate.
CREATE INDEX idx_activities_user_start_time ON activities (user_id, start_time DESC);
