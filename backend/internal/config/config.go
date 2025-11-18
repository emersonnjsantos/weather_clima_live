package config

import (
	"os"
)

// Config contém a configuração da aplicação.
type Config struct {
	OpenWeatherMapAPIKey string
	ValkeyAddress        string
	Port                 string
	DatabaseURL          string
}

// Load carrega a configuração a partir de variáveis de ambiente.
func Load() *Config {
	return &Config{
		OpenWeatherMapAPIKey: os.Getenv("OPENWEATHERMAP_API_KEY"),
		ValkeyAddress:        os.Getenv("VALKEY_ADDRESS"),
		Port:                 getEnv("PORT", "8080"),
		DatabaseURL:          os.Getenv("DATABASE_URL"),
	}
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
