package handlers

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"os"

	mw "github.com/weatherpro/backend/internal/api/middleware"
)

// MapsHandler é um handler para configurações de mapas.
type MapsHandler struct{}

// NewMapsHandler cria um novo MapsHandler.
func NewMapsHandler() *MapsHandler {
	return &MapsHandler{}
}

// GetMapsConfig obtém a configuração para os mapas.
// A chave da API agora é lida de variável de ambiente ao invés de hardcoded.
func (h *MapsHandler) GetMapsConfig(w http.ResponseWriter, r *http.Request) {
	type response struct {
		WindyAPIKey string `json:"windy_api_key"`
	}

	apiKey := os.Getenv("WINDY_API_KEY")
	if apiKey == "" {
		slog.Warn("WINDY_API_KEY not configured")
		mw.WriteError(w, http.StatusServiceUnavailable, "maps service not configured", nil)
		return
	}

	resp := response{
		WindyAPIKey: apiKey,
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}
