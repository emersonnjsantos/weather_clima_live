import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/loading_state_widget.dart';
import './widgets/search_bar_widget.dart';

class CitySearch extends StatefulWidget {
  const CitySearch({super.key});

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final WeatherRepository _weatherRepository = WeatherRepository();

  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<CityWeather> _searchResults = [];
  final List<String> _recentSearches = [];

  // Timer para debounce
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancela o timer anterior se existir
    _debounce?.cancel();

    final query = _searchController.text.trim();

    setState(() {
      _searchQuery = query;
    });

    // Se o campo estiver vazio, limpa os resultados
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    // Se tiver menos de 3 caracteres, não busca
    if (query.length < 3) {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    // Mostra loading enquanto espera
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    // Cria novo timer de 1200ms (debounce aumentado)
    _debounce = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && query == _searchController.text.trim()) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      // Call real API
      final results = await _weatherRepository.searchCities(query);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = results;
          // Se não encontrou resultados, define mensagem amigável
          if (results.isEmpty) {
            _errorMessage = 'Nenhuma cidade encontrada para "$query"';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
          // Mensagem de erro mais amigável
          _errorMessage =
              'Não foi possível buscar a cidade. Verifique sua conexão.';
        });
      }
    }
  }

  void _removeRecentSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  void _selectRecentSearch(String cityName) {
    _searchController.text = cityName;
    _searchFocusNode.unfocus();
    _navigateToWeatherDashboard(cityName);
  }

  void _selectSearchResult(CityWeather city) {
    _searchFocusNode.unfocus();

    // Usa o nome da cidade, mas garante que não está vazio
    String cityName =
        city.name.isNotEmpty ? city.name : '${city.lat},${city.lon}';

    // Add to recent searches
    if (!_recentSearches.contains(cityName)) {
      setState(() {
        _recentSearches.insert(0, cityName);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    _navigateToWeatherDashboard(cityName);
  }

  Future<void> _toggleFavorite(CityWeather city) async {
    try {
      final isFavorite = await _weatherRepository.isFavoriteCity(city.name);

      if (isFavorite) {
        await _weatherRepository.removeFavoriteCity(city.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${city.name} removida dos favoritos'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await _weatherRepository.addFavoriteCity(city.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${city.name} adicionada aos favoritos'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      // Refresh to update favorite status
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar favoritos'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToWeatherDashboard(String cityName) {
    Navigator.pop(context, cityName);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchResults.clear();
      _hasSearched = false;
      _searchQuery = '';
      _errorMessage = null;
    });
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
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App Bar with back button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(2.w),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Buscar Cidades',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              SearchBarWidget(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onClear: _clearSearch,
              ),

              // Content Area
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return LoadingStateWidget();
    }

    if (_hasSearched && _searchQuery.isNotEmpty) {
      if (_searchResults.isEmpty) {
        return _buildNoResultsState();
      }
      return _buildSearchResultsList();
    }

    if (_recentSearches.isNotEmpty) {
      return _buildRecentSearchesList();
    }

    return EmptyStateWidget();
  }

  Widget _buildSearchResultsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            title: Text(city.name),
            subtitle: Text(
                '${city.country} • ${city.temperature.toStringAsFixed(1)}°C'),
            trailing: IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () => _toggleFavorite(city),
            ),
            onTap: () => _selectSearchResult(city),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final cityName = _recentSearches[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            leading: Icon(Icons.history),
            title: Text(cityName),
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _removeRecentSearch(index),
            ),
            onTap: () => _selectRecentSearch(cityName),
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              _errorMessage ?? 'Cidade não encontrada',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Verifique a ortografia e tente novamente.\nExemplo: Curitiba, São Paulo, Rio de Janeiro',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
