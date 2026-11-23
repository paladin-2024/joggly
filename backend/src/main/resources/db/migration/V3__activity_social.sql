CREATE TABLE activity_kudos (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    activity_id UUID NOT NULL,
    user_id UUID NOT NULL,
    CONSTRAINT uq_activity_kudos UNIQUE (activity_id, user_id),
    CONSTRAINT fk_activity_kudos_activity FOREIGN KEY (activity_id) REFERENCES activities (id),
    CONSTRAINT fk_activity_kudos_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_activity_kudos_activity ON activity_kudos (activity_id);

CREATE TABLE activity_comments (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    activity_id UUID NOT NULL,
    user_id UUID NOT NULL,
    body VARCHAR(500) NOT NULL,
    CONSTRAINT fk_activity_comments_activity FOREIGN KEY (activity_id) REFERENCES activities (id),
    CONSTRAINT fk_activity_comments_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_activity_comments_activity ON activity_comments (activity_id, created_at);
