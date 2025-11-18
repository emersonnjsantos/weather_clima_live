package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/google/uuid"
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
	var city domain.FavoriteCity
	if err := json.NewDecoder(r.Body).Decode(&city); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// TODO: Obter o ID do usuário a partir do contexto
	city.UserID = uuid.MustParse("00000000-0000-0000-0000-000000000001")

	if err := h.service.CreateFavoriteCity(r.Context(), &city); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(city); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// GetFavoriteCities busca todas as cidades favoritas de um usuário.
func (h *FavoriteCityHandler) GetFavoriteCities(w http.ResponseWriter, r *http.Request) {
	// TODO: Obter o ID do usuário a partir do contexto
	userID := uuid.MustParse("00000000-0000-0000-0000-000000000001")

	cities, err := h.service.GetFavoriteCitiesByUserID(r.Context(), userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(cities); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// DeleteFavoriteCity remove uma cidade favorita.
func (h *FavoriteCityHandler) DeleteFavoriteCity(w http.ResponseWriter, r *http.Request) {
	idStr := r.URL.Path[len("/favorites/"):]
	id, err := uuid.Parse(idStr)
	if err != nil {
		http.Error(w, "invalid favorite city ID", http.StatusBadRequest)
		return
	}

	if err := h.service.DeleteFavoriteCity(r.Context(), id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
