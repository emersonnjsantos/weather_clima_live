package config

import (
	"os"
	"testing"
)

func TestLoad_MissingAPIKey(t *testing.T) {
	os.Unsetenv("OPENWEATHERMAP_API_KEY")
	os.Unsetenv("DATABASE_URL")

	_, err := Load()
	if err == nil {
		t.Fatal("expected error when OPENWEATHERMAP_API_KEY is missing")
	}
}

func TestLoad_MissingDatabaseURL(t *testing.T) {
	t.Setenv("OPENWEATHERMAP_API_KEY", "test-key")
	os.Unsetenv("DATABASE_URL")

	_, err := Load()
	if err == nil {
		t.Fatal("expected error when DATABASE_URL is missing")
	}
}

func TestLoad_ValidConfig(t *testing.T) {
	t.Setenv("OPENWEATHERMAP_API_KEY", "test-key")
	t.Setenv("DATABASE_URL", "postgres://localhost/test")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if cfg.OpenWeatherMapAPIKey != "test-key" {
		t.Errorf("expected API key 'test-key', got '%s'", cfg.OpenWeatherMapAPIKey)
	}
	if cfg.DatabaseURL != "postgres://localhost/test" {
		t.Errorf("expected DB URL, got '%s'", cfg.DatabaseURL)
	}
}

func TestLoad_DefaultPort(t *testing.T) {
	t.Setenv("OPENWEATHERMAP_API_KEY", "test-key")
	t.Setenv("DATABASE_URL", "postgres://localhost/test")
	os.Unsetenv("PORT")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if cfg.Port != "8080" {
		t.Errorf("expected default port '8080', got '%s'", cfg.Port)
	}
}

func TestLoad_CustomPort(t *testing.T) {
	t.Setenv("OPENWEATHERMAP_API_KEY", "test-key")
	t.Setenv("DATABASE_URL", "postgres://localhost/test")
	t.Setenv("PORT", "3000")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if cfg.Port != "3000" {
		t.Errorf("expected port '3000', got '%s'", cfg.Port)
	}
}
