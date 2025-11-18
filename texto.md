📁 ESTRUTURA DO BACKEND (Go)
1. Arquitetura - Clean Architecture
O backend segue Clean Architecture, separando em camadas:

```
backend/
├── cmd/server/          # Ponto de entrada da aplicação
├── internal/
│   ├── api/            # Camada de apresentação (HTTP)
│   ├── core/           # Camada de negócio (domínio + serviços)
│   ├── platform/       # Camada de infraestrutura (clientes externos, DB, cache)
│   └── config/         # Configurações
├── migrations/         # Migrações do banco de dados
└── docker-compose.yml  # Orquestração de containers
```



📂 main.go
Função: Ponto de entrada da aplicação. Inicializa tudo.

// O que faz:
1. Carrega configurações (.env)
2. Conecta ao PostgreSQL
3. Conecta ao Valkey (Redis)
4. Cria instâncias dos clientes externos (OpenWeatherMap)
5. Injeta dependências nos serviços
6. Configura rotas HTTP
7. Inicia o servidor


Fluxo:
```
Config → DB → Cache → Clientes → Repositórios → Serviços → Handlers → Router → Server
```

📂 internal/config/config.go
Função: Carrega variáveis de ambiente

```go
type Config struct {
    Port                  string  // Porta do servidor (8080)
    DatabaseURL          string  // URL do PostgreSQL
    ValkeyAddress        string  // Endereço do Valkey (Redis)
    OpenWeatherMapAPIKey string  // Chave da API
}

// Usa godotenv para ler o arquivo .env
```

📂 internal/core/domain/ (Domínio - Entidades)
weather.go - Modelos de dados do clima

```go
type WeatherData struct {
    Lat            float64          // Latitude
    Lon            float64          // Longitude
    Timezone       string           // Nome da cidade
    Current        CurrentWeather   // Clima atual
    Hourly         []HourlyForecast // 8 previsões de 3 em 3 horas
    Daily          []DailyForecast  // 6 previsões diárias
}

type CurrentWeather struct {
    Dt         int64     // Timestamp
    Temp       float64   // Temperatura
    FeelsLike  float64   // Sensação térmica
    Pressure   int       // Pressão atmosférica
    Humidity   int       // Umidade
    WindSpeed  float64   // Velocidade do vento
    Weather    []Weather // Condições (chuva, limpo, etc)
}
```

Função: Define como os dados de clima são estruturados na aplicação.

user.go, favorite_city.go, notification_settings.go, subscription.go

```
// Modelos para funcionalidades futuras:
- User: Dados do usuário
- FavoriteCity: Cidades favoritas do usuário
- NotificationSettings: Preferências de notificações
- Subscription: Status de assinatura premium
```

📂 internal/core/services/ (Serviços - Lógica de Negócio)
weather_service.go
Função: Orquestra a busca de clima (cache + API)

```go
func (s *WeatherService) GetWeatherData(ctx, lat, lon) (*WeatherData, error) {
    // 1. Tenta buscar no cache (Valkey)
    cachedData := s.weatherCache.Get(lat, lon)
    if cachedData != nil {
        return cachedData  // Retorna do cache (rápido!)
    }

    // 2. Se não estiver em cache, busca na API
    weatherData := s.weatherClient.GetWeatherData(lat, lon)

    // 3. Salva no cache por 30 minutos
    s.weatherCache.Set(lat, lon, weatherData, 30*time.Minute)

    return weatherData
}
```


Por que usar cache?

Evita múltiplas chamadas à API (economia)
Resposta mais rápida ao usuário
OpenWeatherMap tem limite de requisições gratuitas
📂 internal/platform/ (Infraestrutura)
client.go
Função: Cliente HTTP para a API do OpenWeatherMap

```
func (c *Client) GetWeatherData(lat, lon float64) (*WeatherData, error) {
    // 1. Busca clima atual (/weather endpoint)
    currentWeather := fetchCurrent(lat, lon)

    // 2. Busca previsão de 5 dias (/forecast endpoint)
    forecast := fetchForecast(lat, lon)

    // 3. Converte forecast em hourly (8 primeiros itens = 24h)
    hourly := convertToHourly(forecast.List[:8])

    // 4. Agrupa forecast por dia (6 dias)
    daily := convertToDaily(forecast.List)

    return &WeatherData{
        Current: currentWeather,
        Hourly:  hourly,
        Daily:   daily,
    }
}
```

Conversão de dados:
// API retorna previsões de 3 em 3 horas
// convertToHourly: pega 8 itens (24 horas)
// convertToDaily: agrupa por data, calcula min/max temperatura

cache/weather_cache.go
Função: Cache usando Valkey (Redis) para armazenar clima
func (c *WeatherCache) Get(lat, lon float64) (*WeatherData, error) {
    key := fmt.Sprintf("weather:%f:%f", lat, lon)
    
    // Busca no Redis
    data := c.client.Get(ctx, key)
    
    // Desserializa JSON → WeatherData
    var weather WeatherData
    json.Unmarshal(data, &weather)
    return &weather
}

func (c *WeatherCache) Set(lat, lon, data, expiration) {
    key := fmt.Sprintf("weather:%f:%f", lat, lon)
    
    // Serializa WeatherData → JSON
    json := json.Marshal(data)
    
    // Salva no Redis com TTL de 30 minutos
    c.client.Set(ctx, key, json, expiration)
}


database/ (PostgreSQL - futuro)

// Repositórios para salvar dados persistentes:
- user_repository.go: CRUD de usuários
- favorite_city_repository.go: CRUD de cidades favoritas
- notification_settings_repository.go: Preferências
- subscription_repository.go: Gerenciamento de assinatura

📂 internal/api/ (Camada HTTP)
weather.go
Função: Controlador HTTP para clima

func (h *WeatherHandler) GetWeather(w http.ResponseWriter, r *http.Request) {
    // 1. Extrai parâmetros da URL (?lat=X&lon=Y)
    lat := r.URL.Query().Get("lat")
    lon := r.URL.Query().Get("lon")

    // 2. Valida parâmetros
    if lat == "" || lon == "" {
        http.Error(w, "lat e lon são obrigatórios", 400)
        return
    }

    // 3. Chama o serviço
    weatherData := h.weatherService.GetWeatherData(ctx, lat, lon)

    // 4. Retorna JSON
    json.NewEncoder(w).Encode(weatherData)
}

Rota: GET /weather?lat=-25.35&lon=-54.24

func NewRouter(handlers...) *http.ServeMux {
    mux := http.NewServeMux()

    // Rotas de clima
    mux.HandleFunc("/weather", weatherHandler.GetWeather)

    // Rotas de usuário
    mux.HandleFunc("/register", userHandler.RegisterUser)

    // Rotas de favoritos
    mux.HandleFunc("/favorites", favoriteCityHandler.GetFavoriteCities)  // GET
    mux.HandleFunc("/favorites", favoriteCityHandler.CreateFavoriteCity) // POST
    mux.HandleFunc("/favorites/", favoriteCityHandler.DeleteFavoriteCity) // DELETE

    return mux
}

📂 migrations/ (Banco de Dados)
Função: Scripts SQL para criar/atualizar schema do PostgreSQL


-- 001_create_users_table.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 002_create_favorite_cities_table.sql
CREATE TABLE favorite_cities (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    city_name VARCHAR(255) NOT NULL
);



Executado automaticamente pelo entrypoint.sh ao iniciar container.

📂 Docker
docker-compose.yml
Função: Orquestra 3 containers

services:
  backend:
    build: .                    # Constrói imagem do Go
    ports: ["8080:8080"]        # Expõe porta
    depends_on: [postgres, valkey]  # Aguarda DB
    environment:
      DATABASE_URL: postgres://...
      VALKEY_ADDRESS: valkey:6379

  postgres:
    image: postgres:15-alpine
    volumes: [pgdata:/var/lib/postgresql/data]  # Persistência

  valkey:
    image: valkey/valkey:latest
    volumes: [valkeydata:/data]  # Persistência


    Dockerfile
Função: Cria imagem Docker otimizada (multi-stage)

# Stage 1: Build
FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download          # Download dependências
COPY . .
RUN go build -o /weatherpro-backend ./cmd/server  # Compila

# Stage 2: Runtime (imagem menor)
FROM alpine:latest
COPY --from=builder /weatherpro-backend /weatherpro-backend
COPY migrations /migrations
COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]



Por que multi-stage?

Imagem final é ~30MB (vs ~500MB com Go completo)
Mais rápido para deploy
entrypoint.sh
Função: Script de inicialização

#!/bin/sh
# 1. Roda migrações do banco
migrate -path /migrations -database $DATABASE_URL up

# 2. Inicia servidor Go
/weatherpro-backend


📱 ESTRUTURA DO FRONTEND (Flutter)
Arquitetura - Clean Architecture


lib/
├── main.dart              # Ponto de entrada
├── core/                  # Configurações globais
├── models/                # Entidades (data classes)
├── services/              # Comunicação HTTP
├── repositories/          # Lógica de negócio + cache
├── presentation/          # Telas e widgets (UI)
├── routes/                # Navegação
├── theme/                 # Cores e estilos
└── widgets/               # Componentes reutilizáveis

📄 main.dart
Função: Inicializa o app

void main() async {
  // 1. Inicializa bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configura notificações
  await NotificationService().initialize();

  // 3. Roda app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return Sizer(  // Responsividade
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: AppTheme.lightTheme,  // Tema customizado
          initialRoute: AppRoutes.home,  // Rota inicial
          routes: AppRoutes.routes,  // Todas as rotas
        );
      },
    );
  }
}



📂 weather_models.dart
Função: Modelos de dados (equivalente ao domain do backend)

class WeatherData {
  final double temperature;
  final String location;
  final String condition;
  final List<HourlyWeather> hourlyForecast;  // 8 itens
  final List<DailyWeather> dailyForecast;    // 6 dias

  // Construtor de JSON (deserialização)
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current']['temp'],
      location: json['timezone'],
      hourlyForecast: (json['hourly'] as List)
          .map((e) => HourlyWeather.fromJson(e))
          .toList(),
      // ...
    );
  }
}

Por que .fromJson()?

Flutter recebe JSON da API
Converte automaticamente em objetos Dart
📂 weather_api_service.dart
Função: Cliente HTTP (equivalente ao client.go)

class WeatherApiService {
  final Dio _dio;  // Cliente HTTP (como axios do JS)

  Future<WeatherData> getCurrentWeatherByCoordinates(lat, lon) async {
    // 1. Faz requisição GET ao backend
    final response = await _dio.get(
      '/weather',
      queryParameters: {'lat': lat, 'lon': lon},
    );

    // 2. Converte JSON → WeatherData
    return WeatherData.fromJson(response.data);
  }

  Future<List<CityWeather>> searchCities(String query) async {
    // 1. Usa Geocoding do Android/iOS
    List<Location> locations = await locationFromAddress(query);

    // 2. Para cada localização, busca clima
    for (var loc in locations) {
      WeatherData weather = await getCurrentWeatherByCoordinates(
        loc.latitude,
        loc.longitude
      );
      
      // 3. Monta lista de resultados
      results.add(CityWeather(
        name: place.subAdministrativeArea ?? weather.location,
        temperature: weather.temperature,
      ));
    }
    return results;
  }
}


📂 weather_repository.dart
Função: Orquestra API + Cache local (equivalente ao weather_service.go)

class WeatherRepository {
  final WeatherApiService _apiService;
  final SharedPreferences _prefs;  // Cache local

  Future<WeatherData> getCurrentWeather({lat, lon, cityName}) async {
    // 1. Tenta buscar do cache
    final cached = _getCachedWeatherData();
    if (cached != null && !_isCacheExpired()) {
      return cached;  // Retorna do cache
    }

    // 2. Se não tem cache, busca da API
    WeatherData weatherData;
    if (cityName != null) {
      weatherData = await _apiService.getCurrentWeatherByCity(cityName);
    } else {
      weatherData = await _apiService.getCurrentWeatherByCoordinates(lat, lon);
    }

    // 3. Salva no cache
    _cacheWeatherData(weatherData);

    return weatherData;
  }

  void _cacheWeatherData(WeatherData data) {
    // Serializa para JSON e salva no SharedPreferences
    final json = {
      'temperature': data.temperature,
      'hourly': data.hourlyForecast.map((e) => e.toJson()).toList(),
      // ...
    };
    _prefs.setString('weather_data', jsonEncode(json));
    _prefs.setInt('cache_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
}




📂 presentation/ (Telas)
weather_dashboard/weather_dashboard.dart
Função: Tela principal do app

class WeatherDashboard extends StatefulWidget {
  @override
  _WeatherDashboardState createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final WeatherRepository _repository = WeatherRepository();
  WeatherData? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();  // Carrega clima ao abrir tela
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);

    try {
      // Busca clima pela localização GPS
      Position position = await Geolocator.getCurrentPosition();
      
      final weather = await _repository.getCurrentWeather(
        lat: position.latitude,
        lon: position.longitude,
      );

      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Mostra erro
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return LoadingWidget();
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CurrentWeatherWidget(data: _weatherData),
            HourlyForecastWidget(hourly: _weatherData.hourlyForecast),
            DailyForecastWidget(daily: _weatherData.dailyForecast),
            WeatherMapsPreviewWidget(),
          ],
        ),
      ),
    );
  }
}


Widgets Reutilizáveis
current_weather_widget.dart - Mostra clima atual
class CurrentWeatherWidget extends StatelessWidget {
  final WeatherData data;

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('${data.temperature}°C'),  // Temperatura
          Text(data.location),             // Cidade
          WeatherIcon(condition: data.condition),  // Ícone
        ],
      ),
    );
  }
}



hourly_forecast_widget.dart - Lista horizontal de previsões horárias

ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: hourlyForecast.length,  // 8 itens
  itemBuilder: (context, index) {
    final hour = hourlyForecast[index];
    return HourCard(
      time: hour.time,
      temp: hour.temp,
      icon: hour.icon,
    );
  },
)



daily_forecast_widget.dart - Lista vertical de previsões diárias

ListView.builder(
  itemCount: dailyForecast.length,  // 6 dias
  itemBuilder: (context, index) {
    final day = dailyForecast[index];
    return DayCard(
      date: day.date,
      tempMax: day.tempMax,
      tempMin: day.tempMin,
      icon: day.icon,
    );
  },
)




📂 app_routes.dart
Função: Gerencia navegação entre telas

class AppRoutes {
  static const String home = '/';
  static const String weatherDashboard = '/weather-dashboard';
  static const String citySearch = '/city-search';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => WeatherDashboard(),
    citySearch: (context) => CitySearch(),
    settings: (context) => SettingsScreen(),
  };
}

// Navegação:
Navigator.pushNamed(context, AppRoutes.citySearch);


📂 theme/app_theme.dart
Função: Define cores, fontes e estilos globais

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF6200EE),  // Roxo
    scaffoldBackgroundColor: Color(0xFFF5F5F5),  // Cinza claro
    textTheme: TextTheme(
      titleLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
      bodyMedium: GoogleFonts.poppins(fontSize: 16),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
    ),
  );
}



🔄 FLUXO COMPLETO DE UMA REQUISIÇÃO
Exemplo: Usuário abre o app
Frontend:


1. WeatherDashboard.initState()
   ↓
2. Geolocator.getCurrentPosition() → (-25.35, -54.24)
   ↓
3. WeatherRepository.getCurrentWeather(lat, lon)
   ↓
4. Verifica cache → vazio
   ↓
5. WeatherApiService.getCurrentWeatherByCoordinates()
   ↓
6. Dio.get('http://192.168.3.6:8080/weather?lat=-25.35&lon=-54.24')


Backend:

7. Router recebe GET /weather
   ↓
8. WeatherHandler.GetWeather() extrai lat/lon
   ↓
9. WeatherService.GetWeatherData()
   ↓
10. Verifica WeatherCache (Valkey) → miss
   ↓
11. OpenWeatherMapClient.GetWeatherData()
   ↓
12. HTTP GET → api.openweathermap.org/data/2.5/weather
   ↓
13. HTTP GET → api.openweathermap.org/data/2.5/forecast
   ↓
14. Converte forecast → hourly (8) + daily (6)
   ↓
15. Salva no cache (30 min)
   ↓
16. Retorna JSON ao frontend


Frontend (continuação):17. WeatherData.fromJson(response.data)
   ↓
18. Salva no SharedPreferences (cache local)
   ↓
19. setState() → atualiza UI
   ↓
20. Renderiza widgets:
    - CurrentWeatherWidget (temperatura, cidade)
    - HourlyForecastWidget (8 cards horizontais)
    - DailyForecastWidget (6 cards verticais)



    🎯 RESUMO DAS RESPONSABILIDADES
Camada	               Backend	                   Frontend
Apresentação	      handlers/ (HTTP)	           presentation/ (UI)
Lógica de Negócio	  services/	               repositories/
Comunicação Externa	   clients/	               services/
Cache	              cache/ (Valkey/Redis)	      SharedPreferences
Persistência	      database/ (PostgreSQL)	  SharedPreferences
Modelos	             domain/	                     models/