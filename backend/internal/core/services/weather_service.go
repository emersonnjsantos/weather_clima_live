package services

import (
	"context"
	"time"

	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/platform/cache"
	"github.com/weatherpro/backend/internal/platform/clients/openweathermap"
)

const (
	cacheExpiration = 30 * time.Minute
)

// WeatherService é um serviço para dados de clima.
type WeatherService struct {
	weatherClient *openweathermap.Client
	weatherCache  *cache.WeatherCache
}

// NewWeatherService cria uma nova instância de WeatherService.
func NewWeatherService(weatherClient *openweathermap.Client, weatherCache *cache.WeatherCache) *WeatherService {
	return &WeatherService{
		weatherClient: weatherClient,
		weatherCache:  weatherCache,
	}
}

// GetWeatherData obtém dados de clima para uma latitude e longitude informadas.
func (s *WeatherService) GetWeatherData(ctx context.Context, lat, lon float64) (*domain.WeatherData, error) {
	// Tenta obter os dados primeiro do cache
	cachedData, err := s.weatherCache.Get(ctx, lat, lon)
	if err != nil {
		// Registra o erro, mas não falha a requisição
		// Ainda é possível buscar os dados na API
	}
	if cachedData != nil {
		return cachedData, nil
	}

	// Se não estiver no cache, busca na API
	weatherData, err := s.weatherClient.GetWeatherData(lat, lon)
	if err != nil {
		return nil, err
	}

	// Salva no cache
	err = s.weatherCache.Set(ctx, lat, lon, weatherData, cacheExpiration)
	if err != nil {
		// Registra o erro, mas não falha a requisição
		// Os dados continuam válidos
	}

	return weatherData, nil
}
