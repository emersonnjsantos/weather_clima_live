package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/weatherpro/backend/internal/api"
	"github.com/weatherpro/backend/internal/api/handlers"
	"github.com/weatherpro/backend/internal/config"
	"github.com/weatherpro/backend/internal/core/services"
	"github.com/weatherpro/backend/internal/platform/cache"
	"github.com/weatherpro/backend/internal/platform/clients/openweathermap"
	"github.com/weatherpro/backend/internal/platform/database"
)

func main() {
	// Carrega a configuração
	cfg := config.Load()

	// Inicializa o banco de dados
	db, err := database.NewDB(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Could not connect to database: %v", err)
	}
	defer db.Close()

	// Inicializa o cliente Valkey
	valkeyClient := redis.NewClient(&redis.Options{
		Addr: cfg.ValkeyAddress,
	})

	// Inicializa o cliente do OpenWeatherMap
	httpClient := &http.Client{
		Timeout: 10 * time.Second,
	}
	owmClient := openweathermap.NewClient(httpClient, cfg.OpenWeatherMapAPIKey)

	// Inicializa os repositórios
	userRepo := database.NewUserRepository(db)
	favoriteCityRepo := database.NewFavoriteCityRepository(db)
	notificationSettingsRepo := database.NewNotificationSettingsRepository(db)
	subscriptionRepo := database.NewSubscriptionRepository(db)

	// Inicializa os serviços
	weatherCache := cache.NewWeatherCache(valkeyClient)
	weatherService := services.NewWeatherService(owmClient, weatherCache)
	userService := services.NewUserService(userRepo)
	favoriteCityService := services.NewFavoriteCityService(favoriteCityRepo)
	notificationSettingsService := services.NewNotificationSettingsService(notificationSettingsRepo)
	subscriptionService := services.NewSubscriptionService(subscriptionRepo)

	// Inicializa os handlers
	weatherHandler := handlers.NewWeatherHandler(weatherService)
	userHandler := handlers.NewUserHandler(userService)
	favoriteCityHandler := handlers.NewFavoriteCityHandler(favoriteCityService)
	notificationSettingsHandler := handlers.NewNotificationSettingsHandler(notificationSettingsService)
	subscriptionHandler := handlers.NewSubscriptionHandler(subscriptionService)
	mapsHandler := handlers.NewMapsHandler()

	// Inicializa o roteador
	router := api.NewRouter(weatherHandler, userHandler, favoriteCityHandler, notificationSettingsHandler, subscriptionHandler, mapsHandler)

	// Cria o servidor HTTP
	server := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: router,
	}

	// Inicia o servidor em uma goroutine
	go func() {
		log.Printf("Starting server on port %s", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Could not listen on %s: %v\n", cfg.Port, err)
		}
	}()

	// Encerramento gracioso
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	<-stop

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	log.Println("Shutting down server...")
	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server shutdown failed: %v", err)
	}
	log.Println("Server gracefully stopped")
}
