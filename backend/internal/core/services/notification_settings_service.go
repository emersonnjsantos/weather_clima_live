package services

import (
	"context"

	"github.com/google/uuid"
	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/platform/database"
)

// NotificationSettingsService é um serviço para configurações de notificação.
type NotificationSettingsService struct {
	repo *database.NotificationSettingsRepository
}

// NewNotificationSettingsService cria uma nova instância de NotificationSettingsService.
func NewNotificationSettingsService(repo *database.NotificationSettingsRepository) *NotificationSettingsService {
	return &NotificationSettingsService{
		repo: repo,
	}
}

// GetNotificationSettingsByUserID obtém as configurações de notificação de um usuário.
func (s *NotificationSettingsService) GetNotificationSettingsByUserID(ctx context.Context, userID uuid.UUID) (*domain.NotificationSettings, error) {
	return s.repo.GetNotificationSettingsByUserID(ctx, userID)
}

// UpdateNotificationSettings atualiza as configurações de notificação de um usuário.
func (s *NotificationSettingsService) UpdateNotificationSettings(ctx context.Context, settings *domain.NotificationSettings) error {
	return s.repo.UpdateNotificationSettings(ctx, settings)
}
