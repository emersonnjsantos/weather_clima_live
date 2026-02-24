package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	mw "github.com/weatherpro/backend/internal/api/middleware"
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
		mw.WriteError(w, http.StatusBadRequest, "lat and lon query parameters are required", nil)
		return
	}

	lat, err := strconv.ParseFloat(latStr, 64)
	if err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid lat parameter", err)
		return
	}

	lon, err := strconv.ParseFloat(lonStr, 64)
	if err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid lon parameter", err)
		return
	}

	weatherData, err := h.weatherService.GetWeatherData(r.Context(), lat, lon)
	if err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to retrieve weather data", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(weatherData); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}
