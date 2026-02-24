package handlers

import (
	"encoding/json"
	"net/http"

	mw "github.com/weatherpro/backend/internal/api/middleware"
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
	userID, ok := mw.GetUserID(r.Context())
	if !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	settings, err := h.service.GetNotificationSettingsByUserID(r.Context(), userID)
	if err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to retrieve notification settings", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(settings); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}

// UpdateNotificationSettings atualiza as configurações de notificação de um usuário.
func (h *NotificationSettingsHandler) UpdateNotificationSettings(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.GetUserID(r.Context())
	if !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	var settings domain.NotificationSettings
	if err := json.NewDecoder(r.Body).Decode(&settings); err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid request body", err)
		return
	}

	settings.UserID = userID

	if err := h.service.UpdateNotificationSettings(r.Context(), &settings); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to update notification settings", err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
