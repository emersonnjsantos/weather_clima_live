# ClimaLife - Aplicativo de Previsão do Tempo

Um aplicativo de previsão do tempo moderno baseado em Flutter que utiliza a API OpenWeatherMap para dados meteorológicos em tempo real, previsões e serviços baseados em localização.

##  Funcionalidades

- **Previsão do Tempo em Tempo Real:** Obtenha dados meteorológicos atuais e precisos para qualquer local.
- **Previsão de 7 Dias:** Planeje sua semana com a previsão detalhada para os próximos 7 dias.
- **Busca de Cidades:** Encontre a previsão do tempo para qualquer cidade do mundo.
- **Favoritos:** Salve suas cidades favoritas para acesso rápido.
- **Mapas Meteorológicos Interativos:** Visualize camadas de mapas para temperatura, chuva, vento e nuvens.
- **GPS Inteligente:** Detecta e gerencia o status do GPS para obter a localização do usuário.
- **Notificações:** Receba alertas meteorológicos importantes.
- **Tema Escuro e Claro:** Alterne entre os temas para uma melhor experiência de visualização.

##  Telas do Aplicativo

| | | |
| :---: | :---: | :---: |
| <img src="https://i.imgur.com/example1.png" width="200"/> | <img src="https://i.imgur.com/example2.png" width="200"/> | <img src="https://i.imgur.com/example3.png" width="200"/> |
| **Tela Inicial** | **Detalhes Diários** | **Busca de Cidades** |
| <img src="https://i.imgur.com/example4.png" width="200"/> | <img src="https://i.imgur.com/example5.png" width="200"/> | <img src="https://i.imgur.com/example6.png" width="200"/> |
| **Favoritos** | **Mapas Meteorológicos** | **Menu Lateral com GPS** |

*(Nota: As imagens acima são exemplos e devem ser substituídas por capturas de tela reais do seu aplicativo.)*

##  Pré-requisitos

- Flutter SDK (^3.6.0)
- Dart SDK
- Android Studio / VS Code com as extensões do Flutter
- Android SDK / Xcode (para desenvolvimento iOS)
- **Chave de API do OpenWeatherMap** (gratuita)

## 🛠️ Instalação

### 1. Instalar dependências:
```bash
flutter pub get
```

### 2.  **IMPORTANTE: Configurar a Chave da API**

**O aplicativo não funcionará sem este passo!**

1. Obtenha uma chave gratuita em: [https://openweathermap.org/api](https://openweathermap.org/api)
2. Abra o arquivo `lib/core/constants/api_constants.dart` (ou o local onde sua chave está armazenada).
3. Substitua `'YOUR_API_KEY_HERE'` pela sua chave real.

### 3. Executar o aplicativo:
```bash
flutter run
```

##  APIs de Mapas Meteorológicos

O aplicativo utiliza APIs gratuitas para fornecer mapas meteorológicos interativos:

- **Windy.com:** Fornece camadas de temperatura, precipitação, nuvens e vento com cores vibrantes e dados em tempo real.
- **RainViewer:** Oferece um radar de chuva em tempo real, mostrando a intensidade da precipitação.

##  Funcionalidade de GPS

O menu lateral inclui um controle de GPS que permite:
- Verificar e exibir o status atual do GPS (ligado/desligado).
- Redirecionar o usuário para as configurações do sistema para ativar ou desativar o GPS.
- Exibir as coordenadas de latitude e longitude da localização atual.
- Gerenciar as permissões de localização do aplicativo.

##  Estrutura do Projeto

```
lib/
├── core/           # Utilitários, constantes e serviços principais
├── models/         # Modelos de dados (Weather, News, etc.)
├── presentation/   # Telas e widgets da interface do usuário (UI)
├── repositories/   # Repositórios para buscar e gerenciar dados
├── routes/         # Configuração de rotas de navegação
├── services/       # Serviços de API e outros
├── theme/          # Configuração de temas (claro e escuro)
└── widgets/        # Widgets reutilizáveis
```

##  Agradecimentos
- Construído com [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Dados da API por [OpenWeatherMap](https://openweathermap.org)
- Mapas por [Windy.com](https://www.windy.com) e [RainViewer](https://www.rainviewer.com/)
- Ícones por [OpenWeatherMap](https://openweathermap.org/weather-conditions)