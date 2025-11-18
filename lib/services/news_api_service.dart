import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../models/news_model.dart';

class NewsApiService {
  late final Dio _dio;
  String? _apiKey;

  NewsApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://newsapi.org/v2/',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));

    // Adiciona interceptor para logging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  Future<void> _loadApiKey() async {
    if (_apiKey == null) {
      final envJson = await rootBundle.loadString('env.json');
      final env = json.decode(envJson);
      _apiKey = env['NEWS_API_KEY'];
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception('Chave da API de Notícias não configurada em env.json');
      }
    }
  }

  Future<List<Article>> fetchWeatherNews() async {
    await _loadApiKey();

    try {
      final response = await _dio.get(
        'everything',
        queryParameters: {
          'q':
              '(clima OR tempo OR meteorologia OR previsão OR chuva OR tempestade OR temperatura OR frente fria) AND (Brasil OR Portuguese)',
          'language': 'pt',
          'sortBy': 'publishedAt',
          'apiKey': _apiKey,
          'pageSize':
              30, // Aumentado para 30 artigos para ter mais opções após filtragem
        },
      );

      if (response.statusCode == 200 && response.data['articles'] != null) {
        final List<dynamic> articlesJson = response.data['articles'];
        return articlesJson
            .map((json) => Article.fromJson(json))
            .where((article) =>
                    article.urlToImage != null &&
                    article.description.isNotEmpty &&
                    article.description != 'null' &&
                    _isWeatherRelated(
                        article) // Filtro adicional para garantir relevância
                )
            .take(20) // Limita ao final a 20 artigos mais relevantes
            .toList();
      } else {
        throw Exception(
            'Falha ao carregar notícias: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tempo esgotado ao buscar notícias');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Sem conexão com a internet');
      } else {
        throw Exception('Erro ao buscar notícias: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado ao buscar notícias: $e');
    }
  }

  // Método auxiliar para verificar se o artigo é realmente relacionado ao clima
  bool _isWeatherRelated(Article article) {
    final weatherKeywords = [
      'clima',
      'tempo',
      'meteorologia',
      'previsão',
      'chuva',
      'tempestade',
      'temperatura',
      'frente fria',
      'calor',
      'frio',
      'neve',
      'granizo',
      'vento',
      'umidade',
      'seca',
      'inundação',
      'furacão',
      'ciclone',
      'tornado',
      'nuvens',
      'sol',
      'céu',
    ];

    final titleLower = article.title.toLowerCase();
    final descriptionLower = article.description.toLowerCase();

    // Verifica se pelo menos uma palavra-chave está no título ou descrição
    return weatherKeywords.any((keyword) =>
        titleLower.contains(keyword) || descriptionLower.contains(keyword));
  }
}
