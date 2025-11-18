package domain

import (
	"time"

	"github.com/google/uuid"
)

// Subscription representa a assinatura de um usuário.
type Subscription struct {
	UserID                 uuid.UUID `json:"user_id"`
	PlanLevel              string    `json:"plan_level"`
	CurrentPeriodEndsAt    time.Time `json:"current_period_ends_at"`
	Provider               string    `json:"provider"`
	ProviderSubscriptionID string    `json:"provider_subscription_id"`
}
