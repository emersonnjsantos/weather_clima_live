package handlers

import (
	"encoding/json"
	"net/http"
)

// MapsHandler é um handler para configuração de mapas.
type MapsHandler struct{}

// NewMapsHandler cria um novo MapsHandler.
func NewMapsHandler() *MapsHandler {
	return &MapsHandler{}
}

// GetMapsConfig obtém a configuração para os mapas.
func (h *MapsHandler) GetMapsConfig(w http.ResponseWriter, r *http.Request) {
	type response struct {
		WindyAPIKey string `json:"windy_api_key"`
	}

	resp := response{
		WindyAPIKey: "hardcoded-windy-api-key",
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
