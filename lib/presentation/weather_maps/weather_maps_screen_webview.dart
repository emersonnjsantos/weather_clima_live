import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/weather_api_service.dart';

/// Tela de Mapas de Previsão usando Windy.com Iframe

class WeatherMapsScreenWebView extends StatefulWidget {
  const WeatherMapsScreenWebView({Key? key}) : super(key: key);

  @override
  State<WeatherMapsScreenWebView> createState() =>
      _WeatherMapsScreenWebViewState();
}

class _WeatherMapsScreenWebViewState extends State<WeatherMapsScreenWebView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WeatherApiService _weatherService = WeatherApiService();

  bool _isLoading = true;

  // Localização (Curitiba por padrão)
  double _lat = -25.4284;
  double _lon = -49.2733;
  int _zoom = 8;

  final List<String> _mapTypes = [
    'Temperatura',
    'Vento',
    'Nuvens',
    'Chuva',
    'Pressão',
  ];

  final List<IconData> _mapIcons = [
    Icons.thermostat,
    Icons.air,
    Icons.cloud,
    Icons.water_drop,
    Icons.compress,
  ];

  // Camadas do Windy.com (overlay)
  final Map<String, String> _windyLayers = {
    'Temperatura': 'temp',
    'Vento': 'wind',
    'Nuvens': 'clouds',
    'Chuva': 'rain',
    'Pressão': 'pressure',
  };

  late List<WebViewController> _controllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeControllers();
    _loadCurrentLocation();

    debugPrint('🗺️ === WINDY.COM IFRAME - MAPAS REAIS! ===');
  }

  void _initializeControllers() {
    _controllers = List.generate(5, (index) {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..enableZoom(true)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('Carregando: $progress%');
            },
            onPageStarted: (String url) {
              debugPrint('Página iniciada: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Página carregada: $url');
            },
          ),
        )
        ..loadRequest(Uri.parse(_getWindyUrl(_mapTypes[index])));
      return controller;
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await _weatherService.getCurrentLocation();
      setState(() {
        _lat = position.latitude;
        _lon = position.longitude;
      });
      _updateAllMaps();
    } catch (e) {
      debugPrint('Usando localização padrão: $e');
    }
  }

  void _updateAllMaps() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].loadRequest(Uri.parse(_getWindyUrl(_mapTypes[i])));
    }
  }

  String _getWindyUrl(String mapType) {
    final layer = _windyLayers[mapType] ?? 'temp';

    // URL do iframe oficial do Windy.com - GRATUITO!
    return 'https://embed.windy.com/embed2.html'
        '?lat=$_lat'
        '&lon=$_lon'
        '&detailLat=$_lat'
        '&detailLon=$_lon'
        '&zoom=$_zoom'
        '&level=surface'
        '&overlay=$layer'
        '&product=ecmwf'
        '&menu=&message=&marker=&calendar=now'
        '&pressure=&type=map'
        '&location=coordinates'
        '&detail=&metricWind=default'
        '&metricTemp=default'
        '&radarRange=-1';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Mapas Meteorológicos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _loadCurrentLocation,
              tooltip: 'Atualizar localização',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sobre os Mapas'),
                    content: const Text(
                      'Mapas meteorológicos em tempo real fornecidos por Windy.com\n\n'
                      '✓ Dados atualizados constantemente\n'
                      '✓ Previsões profissionais ECMWF\n'
                      '✓ Cobertura global\n\n'
                      'Toque e arraste para navegar no mapa.\n'
                      'Use dois dedos para zoom.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            isScrollable: true,
            tabs: List.generate(
              5,
              (index) => Tab(
                icon: Icon(_mapIcons[index]),
                text: _mapTypes[index],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 2.h),
                    Text(
                      'Carregando mapas...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Info banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(2.w),
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: const Color(0xFF1976D2),
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Mapas em tempo real do Windy.com - Arraste para navegar',
                            style: TextStyle(
                              color: const Color(0xFF1976D2),
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // WebView com mapas
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        5,
                        (index) => WebViewWidget(
                          controller: _controllers[index],
                          gestureRecognizers: const <Factory<
                              OneSequenceGestureRecognizer>>{},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
