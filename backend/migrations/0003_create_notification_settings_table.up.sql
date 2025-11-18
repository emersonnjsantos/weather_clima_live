CREATE TABLE IF NOT EXISTS notification_settings (
    user_id UUID PRIMARY KEY,
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    status_bar_notification BOOLEAN NOT NULL DEFAULT true,
    rain_alert BOOLEAN NOT NULL DEFAULT true,
    severe_weather_alert BOOLEAN NOT NULL DEFAULT true,
    alert_location_name VARCHAR(255),
    alert_lat DECIMAL,
    alert_lon DECIMAL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
