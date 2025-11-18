CREATE TABLE IF NOT EXISTS subscriptions (
    user_id UUID PRIMARY KEY,
    plan_level VARCHAR(255) NOT NULL DEFAULT 'free',
    current_period_ends_at TIMESTAMPTZ,
    provider VARCHAR(255),
    provider_subscription_id VARCHAR(255) UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
