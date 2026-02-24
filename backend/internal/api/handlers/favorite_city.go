package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/google/uuid"
	mw "github.com/weatherpro/backend/internal/api/middleware"
	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/core/services"
)

// FavoriteCityHandler é um handler para cidades favoritas.
type FavoriteCityHandler struct {
	service *services.FavoriteCityService
}

// NewFavoriteCityHandler cria um novo FavoriteCityHandler.
func NewFavoriteCityHandler(service *services.FavoriteCityService) *FavoriteCityHandler {
	return &FavoriteCityHandler{
		service: service,
	}
}

// CreateFavoriteCity cria uma nova cidade favorita.
func (h *FavoriteCityHandler) CreateFavoriteCity(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.GetUserID(r.Context())
	if !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	var city domain.FavoriteCity
	if err := json.NewDecoder(r.Body).Decode(&city); err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid request body", err)
		return
	}

	city.UserID = userID

	if err := h.service.CreateFavoriteCity(r.Context(), &city); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to create favorite city", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(city); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}

// GetFavoriteCities obtém as cidades favoritas de um usuário.
func (h *FavoriteCityHandler) GetFavoriteCities(w http.ResponseWriter, r *http.Request) {
	userID, ok := mw.GetUserID(r.Context())
	if !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	cities, err := h.service.GetFavoriteCitiesByUserID(r.Context(), userID)
	if err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to retrieve favorite cities", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(cities); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to encode response", err)
	}
}

// DeleteFavoriteCity deleta uma cidade favorita.
func (h *FavoriteCityHandler) DeleteFavoriteCity(w http.ResponseWriter, r *http.Request) {
	if _, ok := mw.GetUserID(r.Context()); !ok {
		mw.WriteError(w, http.StatusUnauthorized, "user not authenticated", nil)
		return
	}

	cityIDStr := r.URL.Query().Get("id")
	if cityIDStr == "" {
		mw.WriteError(w, http.StatusBadRequest, "id query parameter is required", nil)
		return
	}

	cityID, err := uuid.Parse(cityIDStr)
	if err != nil {
		mw.WriteError(w, http.StatusBadRequest, "invalid city id", err)
		return
	}

	if err := h.service.DeleteFavoriteCity(r.Context(), cityID); err != nil {
		mw.WriteError(w, http.StatusInternalServerError, "failed to delete favorite city", err)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
