package api

import (
	"net/http"

	"github.com/weatherpro/backend/internal/api/handlers"
)

// NewRouter cria um novo roteador.
func NewRouter(
	weatherHandler *handlers.WeatherHandler,
	userHandler *handlers.UserHandler,
	favoriteCityHandler *handlers.FavoriteCityHandler,
	notificationSettingsHandler *handlers.NotificationSettingsHandler,
	subscriptionHandler *handlers.SubscriptionHandler,
	mapsHandler *handlers.MapsHandler,
) *http.ServeMux {
	mux := http.NewServeMux()

	mux.HandleFunc("/weather", weatherHandler.GetWeather)
	mux.HandleFunc("/register", userHandler.RegisterUser)

	mux.HandleFunc("/favorites", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			favoriteCityHandler.GetFavoriteCities(w, r)
		case http.MethodPost:
			favoriteCityHandler.CreateFavoriteCity(w, r)
		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})

	mux.HandleFunc("/favorites/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodDelete {
			// Esta é uma forma simples de tratar /favorites/{id}
			// Uma solução mais robusta usaria um roteador que suporte parâmetros de rota
			// O restante da lógica está no handler
			favoriteCityHandler.DeleteFavoriteCity(w, r)
		} else {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})

	mux.HandleFunc("/notifications/settings", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			notificationSettingsHandler.GetNotificationSettings(w, r)
		case http.MethodPut:
			notificationSettingsHandler.UpdateNotificationSettings(w, r)
		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})

	mux.HandleFunc("/subscription", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			subscriptionHandler.GetSubscription(w, r)
		case http.MethodPut:
			subscriptionHandler.UpdateSubscription(w, r)
		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})

	mux.HandleFunc("/maps/config", mapsHandler.GetMapsConfig)

	return mux
}
