package database

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/weatherpro/backend/internal/core/domain"
)

// NotificationSettingsRepository é um repositório para configurações de notificação.
type NotificationSettingsRepository struct {
	db *pgxpool.Pool
}

// NewNotificationSettingsRepository cria uma nova instância de NotificationSettingsRepository.
func NewNotificationSettingsRepository(db *pgxpool.Pool) *NotificationSettingsRepository {
	return &NotificationSettingsRepository{
		db: db,
	}
}

// GetNotificationSettingsByUserID obtém as configurações de notificação de um usuário.
func (r *NotificationSettingsRepository) GetNotificationSettingsByUserID(ctx context.Context, userID uuid.UUID) (*domain.NotificationSettings, error) {
	query := `
		SELECT user_id, is_enabled, status_bar_notification, rain_alert, severe_weather_alert, alert_location_name, alert_lat, alert_lon
		FROM notification_settings
		WHERE user_id = $1
	`
	settings := &domain.NotificationSettings{}
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&settings.UserID,
		&settings.IsEnabled,
		&settings.StatusBarNotification,
		&settings.RainAlert,
		&settings.SevereWeatherAlert,
		&settings.AlertLocationName,
		&settings.AlertLat,
		&settings.AlertLon,
	)
	if err != nil {
		return nil, err
	}
	return settings, nil
}

// UpdateNotificationSettings atualiza as configurações de notificação de um usuário.
func (r *NotificationSettingsRepository) UpdateNotificationSettings(ctx context.Context, settings *domain.NotificationSettings) error {
	query := `
		INSERT INTO notification_settings (user_id, is_enabled, status_bar_notification, rain_alert, severe_weather_alert, alert_location_name, alert_lat, alert_lon)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (user_id) DO UPDATE SET
			is_enabled = EXCLUDED.is_enabled,
			status_bar_notification = EXCLUDED.status_bar_notification,
			rain_alert = EXCLUDED.rain_alert,
			severe_weather_alert = EXCLUDED.severe_weather_alert,
			alert_location_name = EXCLUDED.alert_location_name,
			alert_lat = EXCLUDED.alert_lat,
			alert_lon = EXCLUDED.alert_lon
	`
	_, err := r.db.Exec(ctx, query,
		settings.UserID,
		settings.IsEnabled,
		settings.StatusBarNotification,
		settings.RainAlert,
		settings.SevereWeatherAlert,
		settings.AlertLocationName,
		settings.AlertLat,
		settings.AlertLon,
	)
	return err
}
