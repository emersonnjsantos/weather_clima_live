package services

import (
	"context"

	"github.com/google/uuid"
	"github.com/weatherpro/backend/internal/core/domain"
	"github.com/weatherpro/backend/internal/platform/database"
)

// FavoriteCityService é um serviço para cidades favoritas.
type FavoriteCityService struct {
	repo *database.FavoriteCityRepository
}

// NewFavoriteCityService cria uma nova instância de FavoriteCityService.
func NewFavoriteCityService(repo *database.FavoriteCityRepository) *FavoriteCityService {
	return &FavoriteCityService{
		repo: repo,
	}
}

// CreateFavoriteCity cria uma nova cidade favorita.
func (s *FavoriteCityService) CreateFavoriteCity(ctx context.Context, city *domain.FavoriteCity) error {
	return s.repo.CreateFavoriteCity(ctx, city)
}

// GetFavoriteCitiesByUserID obtém todas as cidades favoritas de um usuário.
func (s *FavoriteCityService) GetFavoriteCitiesByUserID(ctx context.Context, userID uuid.UUID) ([]*domain.FavoriteCity, error) {
	return s.repo.GetFavoriteCitiesByUserID(ctx, userID)
}

// DeleteFavoriteCity remove uma cidade favorita.
func (s *FavoriteCityService) DeleteFavoriteCity(ctx context.Context, id uuid.UUID) error {
	return s.repo.DeleteFavoriteCity(ctx, id)
}
