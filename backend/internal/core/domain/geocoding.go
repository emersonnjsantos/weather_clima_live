package domain

// GeocodingResult representa um resultado de busca de geocodificação.
type GeocodingResult struct {
	Name    string  `json:"name"`
	Country string  `json:"country"`
	State   string  `json:"state,omitempty"`
	Lat     float64 `json:"lat"`
	Lon     float64 `json:"lon"`
}
