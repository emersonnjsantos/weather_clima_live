# Arquitetura do Backend - WeatherPro (ClimaLife)

Este documento descreve a arquitetura do serviço de backend para o aplicativo WeatherPro. O serviço é construído em Go, utiliza Valkey para cache e PostgreSQL como banco de dados, e foi projetado para ser implantado no Google Cloud Run.

## 1. Modelo de Dados (PostgreSQL)

A persistência dos dados é feita em um banco de dados PostgreSQL. As tabelas abaixo representam o estado da aplicação.

### 1.1. `users`
Armazena as informações básicas de autenticação dos usuários.

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Chave Primária | Identificador único do usuário. |
| `email` | VARCHAR | UNIQUE, NOT NULL | Email de login. |
| `password_hash` | VARCHAR | NOT NULL | Hash da senha (ex: bcrypt). |
| `created_at` | TIMESTAMPZ | | Data de criação do registro. |
| `updated_at` | TIMESTAMPZ | | Data da última atualização. |

### 1.2. `user_preferences`
Guarda todas as configurações e personalizações do usuário.

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `user_id` | UUID | Chave Primária, FK `users.id` | Identificador do usuário. |
| `default_city_name`| VARCHAR | | Nome da cidade padrão. |
| `default_lat` | DECIMAL | | Latitude da cidade padrão. |
| `default_lon` | DECIMAL | | Longitude da cidade padrão. |
| `measurement_units`| JSONB | | Objeto com as unidades de medida: `{"temp": "celsius", "speed": "kmh", ...}`. |
| `theme` | VARCHAR | | Tema da UI (ex: 'dark', 'light'). |

### 1.3. `favorite_cities`
Lista de cidades favoritas de cada usuário.

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Chave Primária | Identificador único do favorito. |
| `user_id` | UUID | NOT NULL, FK `users.id` | Identificador do usuário. |
| `city_name` | VARCHAR | NOT NULL | Nome da cidade. |
| `lat` | DECIMAL | NOT NULL | Latitude. |
| `lon` | DECIMAL | NOT NULL | Longitude. |
| `country_code` | VARCHAR(2) | | Código do país (ex: 'BR'). |

### 1.4. `notification_settings`
Configurações de notificação por usuário.

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `user_id` | UUID | Chave Primária, FK `users.id` | Identificador do usuário. |
| `is_enabled` | BOOLEAN | DEFAULT true | Chave geral para notificações. |
| `status_bar_notification`| BOOLEAN | DEFAULT true | Notificação persistente na barra. |
| `rain_alert` | BOOLEAN | DEFAULT true | Alerta de chuva. |
| `severe_weather_alert`| BOOLEAN | DEFAULT true | Alerta de tempo severo. |
| `alert_location_name`| VARCHAR | | Localização para os alertas. |
| `alert_lat` | DECIMAL | | Latitude para os alertas. |
| `alert_lon` | DECIMAL | | Longitude para os alertas. |

### 1.5. `subscriptions`
Gerencia o plano de assinatura de cada usuário.

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `user_id` | UUID | Chave Primária, FK `users.id` | Identificador do usuário. |
| `plan_level` | VARCHAR | NOT NULL, DEFAULT 'free' | Nível do plano (ex: 'free', 'premium'). |
| `current_period_ends_at`| TIMESTAMPZ | | Data de expiração do plano. |
| `provider` | VARCHAR | | Provedor de pagamento (ex: 'stripe'). |
| `provider_subscription_id`| VARCHAR | UNIQUE | ID da assinatura no provedor. |

---

## 2. API REST Endpoints

A API será versionada (`/v1`) e seguirá os princípios REST.

### Autenticação
- `POST /v1/auth/register`: Registra um novo usuário.
- `POST /v1/auth/login`: Autentica e retorna um token JWT.

### Clima (Proxy com Cache Valkey)
- `GET /v1/weather?lat={lat}&lon={lon}`: Retorna dados agregados (atual, horário, diário) para uma coordenada.
- `GET /v1/weather/search?q={cityName}`: Busca cidades por nome.

### Usuário e Preferências
- `GET /v1/me`: Retorna o perfil completo do usuário logado (preferências, favoritos, assinatura).
- `PUT /v1/me/preferences`: Atualiza as preferências do usuário.

### Cidades Favoritas
- `GET /v1/favorites`: Lista as cidades favoritas do usuário.
- `POST /v1/favorites`: Adiciona uma cidade favorita.
- `DELETE /v1/favorites/{favorite_id}`: Remove uma cidade favorita.

### Notificações
- `GET /v1/notifications/settings`: Retorna as configurações de notificação.
- `PUT /v1/notifications/settings`: Atualiza as configurações de notificação.

### Notícias (Proxy)
- `GET /v1/news`: Retorna notícias sobre o clima.

### Mapas
- `GET /v1/maps/config`: Retorna configurações para os mapas do cliente (ex: chaves de API).

---

## 3. Estrutura do Projeto Go

A estrutura segue o padrão "Project Layout" para garantir separação de responsabilidades e testabilidade.

```
/weatherpro-backend
├── cmd/
│   └── server/
│       └── main.go         # Ponto de entrada: inicializa dependências e servidor.
├── internal/
│   ├── api/                # Camada de apresentação (HTTP Handlers, Router, Middleware).
│   ├── core/               # Lógica de negócio (Services, Domain Models).
│   ├── platform/           # Camada de infraestrutura (DB, Cache, API Clients).
│   └── config/             # Gestão de configurações via variáveis de ambiente.
├── pkg/                    # Código reutilizável (se houver).
├── Dockerfile              # Define a imagem do contêiner para deploy.
└── go.mod                  # Gerenciador de dependências.
```

### Componentes Principais:
- **`main.go`**: O "maestro" que inicializa e injeta todas as dependências (DB, Cache, Services, Handlers).
- **Handlers (`internal/api`)**: Responsáveis por tratar as requisições HTTP, chamar os serviços e retornar as respostas.
- **Services (`internal/core`)**: Contêm a lógica de negócio pura, orquestrando as operações entre os repositórios e clientes.
- **Platform (`internal/platform`)**: Implementa os detalhes de infraestrutura:
    - **`database`**: Conexão e queries com o PostgreSQL.
    - **`cache`**: Lógica de `Get`/`Set` para o Valkey.
    - **`clients`**: Clientes HTTP para APIs externas como OpenWeatherMap.

---

## 4. Implantação (Google Cloud Run)

A arquitetura foi pensada para o ambiente serverless do Cloud Run:

- **Containerização (`Dockerfile`)**: Um `Dockerfile` multi-stage gera um contêiner mínimo contendo apenas o binário compilado da aplicação, garantindo um deploy rápido e seguro.
- **Stateless**: A aplicação não guarda estado em memória. Todo estado é externalizado para o PostgreSQL e Valkey, permitindo que o Cloud Run escale o número de instâncias (inclusive a zero) sem perda de dados.
- **Configuração por Variáveis de Ambiente**: Todas as configurações (chaves de API, URLs de conexão) são lidas de variáveis de ambiente, o que é o padrão no Cloud Run.
- **Escalabilidade Horizontal**: Cada instância do contêiner é independente, permitindo que o Cloud Run suba múltiplas instâncias para lidar com picos de tráfego.
