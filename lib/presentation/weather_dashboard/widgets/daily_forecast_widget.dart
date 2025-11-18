import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_models.dart';
import '../../../services/weather_api_service.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyWeather> dailyForecast;

  const DailyForecastWidget({
    super.key,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyForecast.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Previsão de 10 dias',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: const Color(0xFF1976D2),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Lista de dias
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length > 10 ? 10 : dailyForecast.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[200],
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final daily = dailyForecast[index];
              return _buildDailyItem(context, daily, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyItem(BuildContext context, DailyWeather daily, int index) {
    final weatherService = WeatherApiService();
    final isToday = index == 0;

    return InkWell(
      onTap: () {
        // Navegar para a página de detalhes do dia
        Navigator.pushNamed(
          context,
          '/daily-detail',
          arguments: daily,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            // Dia da semana e data
            SizedBox(
              width: 18.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Hoje' : _getDayName(daily.date),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatDate(daily.date),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Ícone do clima
            SizedBox(
              width: 10.w,
              child: Center(
                child: Image.network(
                  weatherService.getWeatherIconUrl(daily.icon, size: '2x'),
                  width: 9.w,
                  height: 9.w,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.wb_sunny,
                      size: 9.w,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ),

            // Probabilidade de chuva
            SizedBox(
              width: 14.w,
              child: daily.precipitation > 0
                  ? Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 12.sp,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          '${daily.precipitation}%',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // Precipitação em mm (se houver)
            SizedBox(
              width: 12.w,
              child: daily.precipitation > 50
                  ? Text(
                      '${(daily.precipitation * 0.2).toStringAsFixed(1)} mm',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
            ),

            // Vento (ícone pequeno)
            SizedBox(
              width: 12.w,
              child: Row(
                children: [
                  Icon(
                    Icons.air,
                    size: 11.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 0.5.w),
                  Flexible(
                    child: Text(
                      '${(daily.high * 0.5).toInt()}-${(daily.high * 0.7).toInt()}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),

            // Temperaturas (máx/mín)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      '${daily.high.round()}°',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[400],
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  Text(
                    '/',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${daily.low.round()}°',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[400],
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),

            // Seta para a direita
            Icon(
              Icons.chevron_right,
              size: 16.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    final days = ['Dom.', 'Seg.', 'Ter.', 'Qua.', 'Qui.', 'Sex.', 'Sáb.'];
    return days[date.weekday % 7];
  }

  String _formatDate(DateTime date) {
    final months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
