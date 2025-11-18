package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/google/uuid"
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
	// TODO: Obter o ID do usuário a partir do contexto
	userID := uuid.MustParse("00000000-0000-0000-0000-000000000001")

	sub, err := h.service.GetSubscriptionByUserID(r.Context(), userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(sub); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// UpdateSubscription atualiza a assinatura de um usuário.
func (h *SubscriptionHandler) UpdateSubscription(w http.ResponseWriter, r *http.Request) {
	var sub domain.Subscription
	if err := json.NewDecoder(r.Body).Decode(&sub); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// TODO: Obter o ID do usuário a partir do contexto
	sub.UserID = uuid.MustParse("00000000-0000-0000-0000-000000000001")

	if err := h.service.UpdateSubscription(r.Context(), &sub); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
