package domain

import "github.com/google/uuid"

// NotificationSettings representa as configurações de notificação de um usuário.
type NotificationSettings struct {
	UserID                uuid.UUID `json:"user_id"`
	IsEnabled             bool      `json:"is_enabled"`
	StatusBarNotification bool      `json:"status_bar_notification"`
	RainAlert             bool      `json:"rain_alert"`
	SevereWeatherAlert    bool      `json:"severe_weather_alert"`
	AlertLocationName     string    `json:"alert_location_name"`
	AlertLat              float64   `json:"alert_lat"`
	AlertLon              float64   `json:"alert_lon"`
}
