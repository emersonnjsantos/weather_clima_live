package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/google/uuid"
	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/core/services"
)

// NotificationSettingsHandler é um handler para configurações de notificação.
type NotificationSettingsHandler struct {
	service *services.NotificationSettingsService
}

// NewNotificationSettingsHandler cria um novo NotificationSettingsHandler.
func NewNotificationSettingsHandler(service *services.NotificationSettingsService) *NotificationSettingsHandler {
	return &NotificationSettingsHandler{
		service: service,
	}
}

// GetNotificationSettings obtém as configurações de notificação de um usuário.
func (h *NotificationSettingsHandler) GetNotificationSettings(w http.ResponseWriter, r *http.Request) {
	// TODO: Obter o ID do usuário a partir do contexto
	userID := uuid.MustParse("00000000-0000-0000-0000-000000000001")

	settings, err := h.service.GetNotificationSettingsByUserID(r.Context(), userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(settings); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// UpdateNotificationSettings atualiza as configurações de notificação de um usuário.
func (h *NotificationSettingsHandler) UpdateNotificationSettings(w http.ResponseWriter, r *http.Request) {
	var settings domain.NotificationSettings
	if err := json.NewDecoder(r.Body).Decode(&settings); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// TODO: Obter o ID do usuário a partir do contexto
	settings.UserID = uuid.MustParse("00000000-0000-0000-0000-000000000001")

	if err := h.service.UpdateNotificationSettings(r.Context(), &settings); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
