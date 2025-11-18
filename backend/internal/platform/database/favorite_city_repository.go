package database

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/weatherpro/backend/internal/core/domain"
)

// FavoriteCityRepository é um repositório para cidades favoritas.
type FavoriteCityRepository struct {
	db *pgxpool.Pool
}

// NewFavoriteCityRepository cria uma nova instância de FavoriteCityRepository.
func NewFavoriteCityRepository(db *pgxpool.Pool) *FavoriteCityRepository {
	return &FavoriteCityRepository{
		db: db,
	}
}

// CreateFavoriteCity cria uma nova cidade favorita no banco de dados.
func (r *FavoriteCityRepository) CreateFavoriteCity(ctx context.Context, city *domain.FavoriteCity) error {
	city.ID = uuid.New()
	query := `
		INSERT INTO favorite_cities (id, user_id, city_name, lat, lon, country_code)
		VALUES ($1, $2, $3, $4, $5, $6)
	`
	_, err := r.db.Exec(ctx, query, city.ID, city.UserID, city.CityName, city.Lat, city.Lon, city.CountryCode)
	return err
}

// GetFavoriteCitiesByUserID obtém todas as cidades favoritas de um usuário.
func (r *FavoriteCityRepository) GetFavoriteCitiesByUserID(ctx context.Context, userID uuid.UUID) ([]*domain.FavoriteCity, error) {
	query := `
		SELECT id, user_id, city_name, lat, lon, country_code
		FROM favorite_cities
		WHERE user_id = $1
	`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cities []*domain.FavoriteCity
	for rows.Next() {
		city := &domain.FavoriteCity{}
		err := rows.Scan(&city.ID, &city.UserID, &city.CityName, &city.Lat, &city.Lon, &city.CountryCode)
		if err != nil {
			return nil, err
		}
		cities = append(cities, city)
	}

	return cities, nil
}

// DeleteFavoriteCity remove uma cidade favorita do banco de dados.
func (r *FavoriteCityRepository) DeleteFavoriteCity(ctx context.Context, id uuid.UUID) error {
	query := `
		DELETE FROM favorite_cities
		WHERE id = $1
	`
	_, err := r.db.Exec(ctx, query, id)
	return err
}
