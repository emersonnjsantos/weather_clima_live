package database

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/weatherpro/backend/internal/core/domain"
)

// SubscriptionRepository é um repositório para assinaturas.
type SubscriptionRepository struct {
	db *pgxpool.Pool
}

// NewSubscriptionRepository cria uma nova instância de SubscriptionRepository.
func NewSubscriptionRepository(db *pgxpool.Pool) *SubscriptionRepository {
	return &SubscriptionRepository{
		db: db,
	}
}

// GetSubscriptionByUserID obtém a assinatura de um usuário.
func (r *SubscriptionRepository) GetSubscriptionByUserID(ctx context.Context, userID uuid.UUID) (*domain.Subscription, error) {
	query := `
		SELECT user_id, plan_level, current_period_ends_at, provider, provider_subscription_id
		FROM subscriptions
		WHERE user_id = $1
	`
	sub := &domain.Subscription{}
	err := r.db.QueryRow(ctx, query, userID).Scan(
		&sub.UserID,
		&sub.PlanLevel,
		&sub.CurrentPeriodEndsAt,
		&sub.Provider,
		&sub.ProviderSubscriptionID,
	)
	if err != nil {
		return nil, err
	}
	return sub, nil
}

// UpdateSubscription atualiza a assinatura de um usuário.
func (r *SubscriptionRepository) UpdateSubscription(ctx context.Context, sub *domain.Subscription) error {
	query := `
		INSERT INTO subscriptions (user_id, plan_level, current_period_ends_at, provider, provider_subscription_id)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (user_id) DO UPDATE SET
			plan_level = EXCLUDED.plan_level,
			current_period_ends_at = EXCLUDED.current_period_ends_at,
			provider = EXCLUDED.provider,
			provider_subscription_id = EXCLUDED.provider_subscription_id
	`
	_, err := r.db.Exec(ctx, query,
		sub.UserID,
		sub.PlanLevel,
		sub.CurrentPeriodEndsAt,
		sub.Provider,
		sub.ProviderSubscriptionID,
	)
	return err
}
