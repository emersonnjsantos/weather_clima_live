package services

import (
	"context"

	"github.com/google/uuid"
	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/platform/database"
)

// SubscriptionService é um serviço para assinaturas.
type SubscriptionService struct {
	repo *database.SubscriptionRepository
}

// NewSubscriptionService cria uma nova instância de SubscriptionService.
func NewSubscriptionService(repo *database.SubscriptionRepository) *SubscriptionService {
	return &SubscriptionService{
		repo: repo,
	}
}

// GetSubscriptionByUserID obtém a assinatura de um usuário.
func (s *SubscriptionService) GetSubscriptionByUserID(ctx context.Context, userID uuid.UUID) (*domain.Subscription, error) {
	return s.repo.GetSubscriptionByUserID(ctx, userID)
}

// UpdateSubscription atualiza a assinatura de um usuário.
func (s *SubscriptionService) UpdateSubscription(ctx context.Context, sub *domain.Subscription) error {
	return s.repo.UpdateSubscription(ctx, sub)
}
