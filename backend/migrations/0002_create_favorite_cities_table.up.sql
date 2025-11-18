CREATE TABLE IF NOT EXISTS favorite_cities (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    city_name VARCHAR(255) NOT NULL,
    lat DECIMAL NOT NULL,
    lon DECIMAL NOT NULL,
    country_code VARCHAR(2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
