package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/weatherpro/backend/internal/core/services"
)

// WeatherHandler é um handler para dados de clima.
type WeatherHandler struct {
	weatherService *services.WeatherService
}

// NewWeatherHandler cria um novo WeatherHandler.
func NewWeatherHandler(weatherService *services.WeatherService) *WeatherHandler {
	return &WeatherHandler{
		weatherService: weatherService,
	}
}

// GetWeather obtém dados de clima para uma latitude e longitude informadas.
func (h *WeatherHandler) GetWeather(w http.ResponseWriter, r *http.Request) {
	latStr := r.URL.Query().Get("lat")
	lonStr := r.URL.Query().Get("lon")

	if latStr == "" || lonStr == "" {
		http.Error(w, "lat and lon query parameters are required", http.StatusBadRequest)
		return
	}

	lat, err := strconv.ParseFloat(latStr, 64)
	if err != nil {
		http.Error(w, "invalid lat parameter", http.StatusBadRequest)
		return
	}

	lon, err := strconv.ParseFloat(lonStr, 64)
	if err != nil {
		http.Error(w, "invalid lon parameter", http.StatusBadRequest)
		return
	}

	weatherData, err := h.weatherService.GetWeatherData(r.Context(), lat, lon)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(weatherData); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
