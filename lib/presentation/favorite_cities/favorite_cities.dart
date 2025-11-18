import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_favorites_widget.dart';
import './widgets/favorite_city_card_widget.dart';

class FavoriteCities extends StatefulWidget {
  const FavoriteCities({super.key});

  @override
  State<FavoriteCities> createState() => _FavoriteCitiesState();
}

class _FavoriteCitiesState extends State<FavoriteCities>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditMode = false;
  bool _isRefreshing = false;
  final List<String> _selectedCities = [];

  // Dados simulados para cidades favoritas
  final List<Map<String, dynamic>> _favoriteCities = [
    {
      "id": "1",
      "cityName": "São Paulo",
      "country": "Brasil",
      "temperature": 28,
      "condition": "Ensolarado",
      "weatherIcon": "sunny",
      "highTemp": 32,
      "lowTemp": 22,
      "localTime": "14:30",
      "lastUpdated": "Há 15 min",
      "isDefault": true,
    },
    {
      "id": "2",
      "cityName": "Rio de Janeiro",
      "country": "Brasil",
      "temperature": 31,
      "condition": "Parcialmente nublado",
      "weatherIcon": "partly_cloudy_day",
      "highTemp": 34,
      "lowTemp": 25,
      "localTime": "14:30",
      "lastUpdated": "Há 20 min",
      "isDefault": false,
    },
    {
      "id": "3",
      "cityName": "Brasília",
      "country": "Brasil",
      "temperature": 26,
      "condition": "Nublado",
      "weatherIcon": "cloud",
      "highTemp": 29,
      "lowTemp": 18,
      "localTime": "14:30",
      "lastUpdated": "Há 10 min",
      "isDefault": false,
    },
    {
      "id": "4",
      "cityName": "Salvador",
      "country": "Brasil",
      "temperature": 29,
      "condition": "Chuva leve",
      "weatherIcon": "light_rain",
      "highTemp": 31,
      "lowTemp": 26,
      "localTime": "14:30",
      "lastUpdated": "Há 5 min",
      "isDefault": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simula atraso de chamada de API
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dados meteorológicos atualizados',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedCities.clear();
      }
    });
  }

  void _toggleCitySelection(String cityId) {
    setState(() {
      if (_selectedCities.contains(cityId)) {
        _selectedCities.remove(cityId);
      } else {
        _selectedCities.add(cityId);
      }
    });
  }

  void _deleteSelectedCities() {
    if (_selectedCities.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Excluir Cidades',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Tem certeza de que deseja excluir ${_selectedCities.length} cidade(s) dos favoritos?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondaryLight),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _favoriteCities.removeWhere(
                    (city) => _selectedCities.contains(city["id"]),
                  );
                  _selectedCities.clear();
                  _isEditMode = false;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cidades removidas dos favoritos',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                  ),
                );
              },
              child: Text(
                'Excluir',
                style: TextStyle(color: AppTheme.errorLight),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCitySearch() {
    Navigator.pushNamed(context, '/city-search');
  }

  void _navigateToWeatherDashboard(Map<String, dynamic> cityData) {
    Navigator.pushNamed(context, '/weather-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          elevation: AppTheme.lightTheme.appBarTheme.elevation,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
          title: Text(
            'Cidades Favoritas',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          actions: [
            if (_favoriteCities.isNotEmpty)
              _isEditMode
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedCities.isNotEmpty)
                          IconButton(
                            onPressed: _deleteSelectedCities,
                            icon: CustomIconWidget(
                              iconName: 'delete',
                              color: AppTheme.errorLight,
                              size: 24,
                            ),
                          ),
                        TextButton(
                          onPressed: _toggleEditMode,
                          child: Text(
                            'Concluído',
                            style: TextStyle(
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: _toggleEditMode,
                      child: Text(
                        'Editar',
                        style: TextStyle(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            IconButton(
              onPressed: _navigateToCitySearch,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Favoritos'),
              Tab(text: 'Recentes'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFavoritesTab(),
              _buildRecentsTab(),
            ],
          ),
        ),
        floatingActionButton: _favoriteCities.isNotEmpty && !_isEditMode
            ? FloatingActionButton(
                onPressed: _navigateToCitySearch,
                backgroundColor: AppTheme.lightTheme.primaryColor,
                child: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteCities.isEmpty) {
      return EmptyFavoritesWidget(
        onAddCity: _navigateToCitySearch,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshWeatherData,
      color: AppTheme.lightTheme.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: 4.w,
          right: 4.w,
          top: 2.h,
          bottom: MediaQuery.of(context).padding.bottom + 2.h,
        ),
        itemCount: _favoriteCities.length,
        itemBuilder: (context, index) {
          final cityData = _favoriteCities[index];
          final isSelected = _selectedCities.contains(cityData["id"]);

          return FavoriteCityCardWidget(
            cityData: cityData,
            isEditMode: _isEditMode,
            isSelected: isSelected,
            isRefreshing: _isRefreshing,
            onTap: _isEditMode
                ? () => _toggleCitySelection(cityData["id"])
                : () => _navigateToWeatherDashboard(cityData),
            onLongPress: () {
              if (!_isEditMode) {
                _toggleEditMode();
                _toggleCitySelection(cityData["id"]);
              }
            },
            onDelete: (cityId) {
              setState(() {
                _favoriteCities.removeWhere((city) => city["id"] == cityId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cidade removida dos favoritos',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
            onSetDefault: (cityId) {
              setState(() {
                for (var city in _favoriteCities) {
                  city["isDefault"] = city["id"] == cityId;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cidade definida como padrão',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
            onShare: (cityData) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Compartilhando dados do tempo de ${cityData["cityName"]}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: AppTheme.textSecondaryLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Nenhuma cidade recente',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'As cidades que você pesquisar aparecerão aqui',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
