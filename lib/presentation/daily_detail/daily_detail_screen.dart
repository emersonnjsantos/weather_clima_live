import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../models/weather_models.dart';
import '../../services/weather_api_service.dart';

class DailyDetailScreen extends StatelessWidget {
  const DailyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyWeather daily =
        ModalRoute.of(context)!.settings.arguments as DailyWeather;
    final weatherService = WeatherApiService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // App Bar com botão voltar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 6.w,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDayName(daily.date),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        Text(
                          _formatDate(daily.date),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo scrollável
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                children: [
                  // Card principal com ícone e temperaturas
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1976D2),
                          const Color(0xFF1976D2).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Ícone grande do clima
                        Image.network(
                          weatherService.getWeatherIconUrl(daily.icon,
                              size: '4x'),
                          width: 30.w,
                          height: 30.w,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.wb_sunny,
                              size: 30.w,
                              color: Colors.white,
                            );
                          },
                        ),
                        SizedBox(height: 2.h),

                        // Descrição do clima
                        Text(
                          daily.description,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),

                        // Temperaturas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  '${daily.high.round()}°',
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Máxima',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 80,
                              color: Colors.white30,
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  '${daily.low.round()}°',
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Mínima',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Card de Precipitação
                  _buildInfoCard(
                    icon: Icons.water_drop,
                    iconColor: Colors.blue,
                    title: 'Precipitação',
                    value: '${daily.precipitation}%',
                    subtitle:
                        'Chance de chuva: ${daily.precipitation > 70 ? 'Alta' : daily.precipitation > 40 ? 'Moderada' : 'Baixa'}',
                  ),

                  SizedBox(height: 2.h),

                  // Card de Vento (estimado)
                  _buildInfoCard(
                    icon: Icons.air,
                    iconColor: Colors.green,
                    title: 'Vento',
                    value: '${(daily.high * 0.6).toInt()} km/h',
                    subtitle:
                        'Rajadas de até ${(daily.high * 0.8).toInt()} km/h',
                  ),

                  SizedBox(height: 2.h),

                  // Card de Umidade (estimada)
                  _buildInfoCard(
                    icon: Icons.opacity,
                    iconColor: Colors.cyan,
                    title: 'Umidade',
                    value: '${60 + daily.precipitation ~/ 3}%',
                    subtitle: 'Umidade relativa do ar',
                  ),

                  SizedBox(height: 2.h),

                  // Card de Índice UV (estimado)
                  _buildInfoCard(
                    icon: Icons.wb_sunny,
                    iconColor: Colors.orange,
                    title: 'Índice UV',
                    value: _getUVLevel(daily.icon),
                    subtitle: 'Use protetor solar nas horas de pico',
                  ),

                  SizedBox(height: 2.h),

                  // Card de Visibilidade
                  _buildInfoCard(
                    icon: Icons.visibility,
                    iconColor: Colors.purple,
                    title: 'Visibilidade',
                    value: daily.precipitation > 50 ? '5 km' : '10 km',
                    subtitle: daily.precipitation > 50
                        ? 'Reduzida por chuva'
                        : 'Boa visibilidade',
                  ),

                  SizedBox(height: 3.h),

                  // Dica do dia
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.amber[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber[700],
                          size: 24.sp,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dica do dia',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                _getTipOfTheDay(daily),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) return 'Hoje';
    if (date.day == now.day + 1 && date.month == now.month) return 'Amanhã';

    final days = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado'
    ];
    return days[date.weekday % 7];
  }

  String _formatDate(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _getUVLevel(String iconCode) {
    if (iconCode.contains('01')) return 'Alto (8-10)';
    if (iconCode.contains('02')) return 'Moderado (5-7)';
    return 'Baixo (1-4)';
  }

  String _getTipOfTheDay(DailyWeather daily) {
    if (daily.precipitation > 70) {
      return 'Alta probabilidade de chuva. Leve um guarda-chuva!';
    } else if (daily.precipitation > 40) {
      return 'Pode chover durante o dia. Tenha um guarda-chuva por precaução.';
    } else if (daily.high > 30) {
      return 'Dia quente! Mantenha-se hidratado e use protetor solar.';
    } else if (daily.low < 10) {
      return 'Noite fria. Vista roupas adequadas.';
    } else {
      return 'Dia agradável! Aproveite atividades ao ar livre.';
    }
  }
}
