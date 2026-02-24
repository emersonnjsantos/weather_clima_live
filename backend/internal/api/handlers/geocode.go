package handlers

import (
	"encoding/json"
	"net/http"

	mw "github.com/weatherpro/backend/internal/api/middleware"
	"github.com/weatherpro/backend/internal/core/services"
)

// GeocodeHandler lida com requisições de geocodificação.
type GeocodeHandler struct {
	weatherService *services.WeatherService
}

// NewGeocodeHandler cria um novo GeocodeHandler.
func NewGeocodeHandler(weatherService *services.WeatherService) *GeocodeHandler {
	return &GeocodeHandler{weatherService: weatherService}
}

// SearchCities busca cidades pelo nome usando a API de geocodificação do OWM.
func (h *GeocodeHandler) SearchCities(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query().Get("q")
	if query == "" {
		mw.WriteError(w, http.StatusBadRequest, "q query parameter is required", nil)
		return
	}

	cities, err := h.weatherService.SearchCities(r.Context(), query)
	if err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to search cities", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(cities); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}
