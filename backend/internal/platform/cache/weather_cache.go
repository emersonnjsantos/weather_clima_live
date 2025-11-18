package cache

import (
	"context"
	"encoding/json"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/weatherpro/backend/internal/core/domain"
)

// WeatherCache é um cache para dados de clima.
type WeatherCache struct {
	client *redis.Client
}

// NewWeatherCache cria uma nova instância de WeatherCache.
func NewWeatherCache(client *redis.Client) *WeatherCache {
	return &WeatherCache{
		client: client,
	}
}

// Get obtém dados de clima do cache.
func (c *WeatherCache) Get(ctx context.Context, lat, lon float64) (*domain.WeatherData, error) {
	key := c.getCacheKey(lat, lon)
	val, err := c.client.Get(ctx, key).Result()
	if err == redis.Nil {
		return nil, nil // Cache vazio
	} else if err != nil {
		return nil, err
	}

	var weatherData domain.WeatherData
	if err := json.Unmarshal([]byte(val), &weatherData); err != nil {
		return nil, err
	}

	return &weatherData, nil
}

// Set armazena dados de clima no cache.
func (c *WeatherCache) Set(ctx context.Context, lat, lon float64, data *domain.WeatherData, expiration time.Duration) error {
	key := c.getCacheKey(lat, lon)
	val, err := json.Marshal(data)
	if err != nil {
		return err
	}

	return c.client.Set(ctx, key, val, expiration).Err()
}

func (c *WeatherCache) getCacheKey(lat, lon float64) string {
	return "weather:" + formatFloat(lat) + ":" + formatFloat(lon)
}

func formatFloat(f float64) string {
	return strconv.FormatFloat(f, 'f', -1, 64)
}
