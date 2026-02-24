package handlers

import (
	"encoding/json"
	"net/http"

	mw "github.com/weatherpro/backend/internal/api/middleware"
	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/core/services"
)

// SubscriptionHandler é um handler para assinaturas.
type SubscriptionHandler struct {
	service *services.SubscriptionService
}

// NewSubscriptionHandler cria um novo SubscriptionHandler.
func NewSubscriptionHandler(service *services.SubscriptionService) *SubscriptionHandler {
	return &SubscriptionHandler{
		service: service,
	}
}

// GetSubscription obtém a assinatura de um usuário.
func (h *SubscriptionHandler) GetSubscription(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.GetUserID(r.Context())
	if !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	subscription, err := h.service.GetSubscriptionByUserID(r.Context(), userID)
	if err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to retrieve subscription", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(subscription); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}

// UpdateSubscription atualiza a assinatura de um usuário.
func (h *SubscriptionHandler) UpdateSubscription(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.GetUserID(r.Context())
	if !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	var sub domain.Subscription
	if err := json.NewDecoder(r.Body).Decode(&sub); err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid request body", err)
		return
	}

	sub.UserID = userID

	if err := h.service.UpdateSubscription(r.Context(), &sub); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to update subscription", err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
