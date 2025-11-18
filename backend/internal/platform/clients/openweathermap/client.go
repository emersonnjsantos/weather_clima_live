package openweathermap

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/weatherpro/backend/internal/core/domain"
)

const (
	currentWeatherAPIURL = "https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%s&units=metric&lang=pt_br"
	forecastAPIURL       = "https://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=%s&units=metric&lang=pt_br"
)

// Estruturas de resposta para a API /weather
type weatherResponse struct {
	Coord struct {
		Lon float64 `json:"lon"`
		Lat float64 `json:"lat"`
	} `json:"coord"`
	Weather []domain.Weather `json:"weather"`
	Main    struct {
		Temp      float64 `json:"temp"`
		FeelsLike float64 `json:"feels_like"`
		Pressure  int     `json:"pressure"`
		Humidity  int     `json:"humidity"`
	} `json:"main"`
	Visibility int `json:"visibility"`
	Wind       struct {
		Speed float64 `json:"speed"`
		Deg   int     `json:"deg"`
	} `json:"wind"`
	Clouds struct {
		All int `json:"all"`
	} `json:"clouds"`
	Dt  int64 `json:"dt"`
	Sys struct {
		Sunrise int64 `json:"sunrise"`
		Sunset  int64 `json:"sunset"`
	} `json:"sys"`
	Timezone int    `json:"timezone"`
	Name     string `json:"name"`
}

// Estruturas de resposta para a API /forecast
type forecastResponse struct {
	List []forecastItem `json:"list"`
}

type forecastItem struct {
	Dt      int64            `json:"dt"`
	Main    mainData         `json:"main"`
	Weather []domain.Weather `json:"weather"`
	Clouds  struct {
		All int `json:"all"`
	} `json:"clouds"`
	Wind struct {
		Speed float64 `json:"speed"`
		Deg   int     `json:"deg"`
		Gust  float64 `json:"gust"`
	} `json:"wind"`
	Pop   float64 `json:"pop"`
	DtTxt string  `json:"dt_txt"`
}

type mainData struct {
	Temp      float64 `json:"temp"`
	FeelsLike float64 `json:"feels_like"`
	TempMin   float64 `json:"temp_min"`
	TempMax   float64 `json:"temp_max"`
	Pressure  int     `json:"pressure"`
	Humidity  int     `json:"humidity"`
}

// Client é um cliente para a API do OpenWeatherMap.
type Client struct {
	httpClient *http.Client
	apiKey     string
}

// NewClient cria um novo cliente da API OpenWeatherMap.
func NewClient(httpClient *http.Client, apiKey string) *Client {
	return &Client{
		httpClient: httpClient,
		apiKey:     apiKey,
	}
}

// GetWeatherData busca dados de clima para uma latitude e longitude informadas.
func (c *Client) GetWeatherData(lat, lon float64) (*domain.WeatherData, error) {
	// 1. Buscar clima atual
	currentURL := fmt.Sprintf(currentWeatherAPIURL, lat, lon, c.apiKey)
	currentResp, err := c.httpClient.Get(currentURL)
	if err != nil {
		return nil, fmt.Errorf("failed to get current weather data: %w", err)
	}
	defer currentResp.Body.Close()

	if currentResp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to get current weather data: status code %d", currentResp.StatusCode)
	}

	var current weatherResponse
	if err := json.NewDecoder(currentResp.Body).Decode(&current); err != nil {
		return nil, fmt.Errorf("failed to decode current weather data: %w", err)
	}

	// Monta a estrutura principal com os dados atuais
	weatherData := &domain.WeatherData{
		Lat:            current.Coord.Lat,
		Lon:            current.Coord.Lon,
		Timezone:       current.Name,
		TimezoneOffset: current.Timezone,
		Current: domain.CurrentWeather{
			Dt:         current.Dt,
			Sunrise:    current.Sys.Sunrise,
			Sunset:     current.Sys.Sunset,
			Temp:       current.Main.Temp,
			FeelsLike:  current.Main.FeelsLike,
			Pressure:   current.Main.Pressure,
			Humidity:   current.Main.Humidity,
			Clouds:     current.Clouds.All,
			Visibility: current.Visibility,
			WindSpeed:  current.Wind.Speed,
			WindDeg:    current.Wind.Deg,
			Weather:    current.Weather,
		},
		Hourly: []domain.HourlyForecast{}, // Inicializa como vazio
		Daily:  []domain.DailyForecast{},  // Inicializa como vazio
	}

	// 2. Buscar previsão de 5 dias / 3 horas
	forecastURL := fmt.Sprintf(forecastAPIURL, lat, lon, c.apiKey)
	forecastResp, err := c.httpClient.Get(forecastURL)
	if err != nil {
		// Se a previsão falhar, retorna ao menos os dados atuais
		return weatherData, nil
	}
	defer forecastResp.Body.Close()

	if forecastResp.StatusCode == http.StatusOK {
		var forecast forecastResponse
		if err := json.NewDecoder(forecastResp.Body).Decode(&forecast); err == nil {
			weatherData.Hourly = convertToHourly(forecast.List)
			weatherData.Daily = convertToDaily(forecast.List)
		}
	}

	return weatherData, nil
}

// Converte os primeiros 8 itens (24h) para a previsão por hora.
func convertToHourly(items []forecastItem) []domain.HourlyForecast {
	count := 8
	if len(items) < count {
		count = len(items)
	}

	hourly := make([]domain.HourlyForecast, count)
	for i := 0; i < count; i++ {
		item := items[i]
		hourly[i] = domain.HourlyForecast{
			Dt:        item.Dt,
			Temp:      item.Main.Temp,
			FeelsLike: item.Main.FeelsLike,
			Pressure:  item.Main.Pressure,
			Humidity:  item.Main.Humidity,
			Clouds:    item.Clouds.All,
			WindSpeed: item.Wind.Speed,
			WindDeg:   item.Wind.Deg,
			WindGust:  item.Wind.Gust,
			Pop:       item.Pop,
			Weather:   item.Weather,
		}
	}
	return hourly
}

// Agrupa os itens por dia para criar a previsão diária.
func convertToDaily(items []forecastItem) []domain.DailyForecast {
	// Agrupa por data mantendo ordem cronológica
	type dailyGroup struct {
		date  string
		items []forecastItem
	}

	seenDates := make(map[string]int) // data -> índice no slice
	orderedGroups := []dailyGroup{}

	for _, item := range items {
		date := time.Unix(item.Dt, 0).Format("2006-01-02")

		if idx, exists := seenDates[date]; exists {
			// Data já existe, adiciona ao grupo
			orderedGroups[idx].items = append(orderedGroups[idx].items, item)
		} else {
			// Nova data, cria novo grupo
			seenDates[date] = len(orderedGroups)
			orderedGroups = append(orderedGroups, dailyGroup{
				date:  date,
				items: []forecastItem{item},
			})
		}
	}

	// Limita a 6 dias e converte para DailyForecast
	maxDays := 6
	if len(orderedGroups) > maxDays {
		orderedGroups = orderedGroups[:maxDays]
	}

	dailyForecasts := make([]domain.DailyForecast, 0, len(orderedGroups))
	for _, group := range orderedGroups {
		dailyItems := group.items
		if len(dailyItems) == 0 {
			continue
		}

		// Usa o item do meio-dia (ou o primeiro) como representativo
		representativeItem := dailyItems[len(dailyItems)/2]
		minTemp := dailyItems[0].Main.TempMin
		maxTemp := dailyItems[0].Main.TempMax
		pop := dailyItems[0].Pop

		for _, item := range dailyItems {
			if item.Main.TempMin < minTemp {
				minTemp = item.Main.TempMin
			}
			if item.Main.TempMax > maxTemp {
				maxTemp = item.Main.TempMax
			}
			if item.Pop > pop {
				pop = item.Pop
			}
		}

		dailyForecasts = append(dailyForecasts, domain.DailyForecast{
			Dt:      representativeItem.Dt,
			Sunrise: 0, // /forecast não fornece isso por dia
			Sunset:  0, // /forecast não fornece isso por dia
			Summary: representativeItem.Weather[0].Description,
			Temp: domain.Temp{
				Min: minTemp,
				Max: maxTemp,
				Day: representativeItem.Main.Temp,
			},
			FeelsLike: domain.FeelsLike{Day: representativeItem.Main.FeelsLike},
			Pressure:  representativeItem.Main.Pressure,
			Humidity:  representativeItem.Main.Humidity,
			WindSpeed: representativeItem.Wind.Speed,
			WindDeg:   representativeItem.Wind.Deg,
			Weather:   representativeItem.Weather,
			Clouds:    representativeItem.Clouds.All,
			Pop:       pop,
		})
	}
	return dailyForecasts
}
