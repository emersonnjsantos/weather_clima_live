package domain

import "github.com/google/uuid"

// FavoriteCity representa uma cidade favorita de um usuário.
type FavoriteCity struct {
	ID          uuid.UUID `json:"id"`
	UserID      uuid.UUID `json:"user_id"`
	CityName    string    `json:"city_name"`
	Lat         float64   `json:"lat"`
	Lon         float64   `json:"lon"`
	CountryCode string    `json:"country_code"`
}
