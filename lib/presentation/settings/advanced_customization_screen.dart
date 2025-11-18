import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AdvancedCustomizationScreen extends StatefulWidget {
  const AdvancedCustomizationScreen({super.key});

  @override
  State<AdvancedCustomizationScreen> createState() =>
      _AdvancedCustomizationScreenState();
}

class _AdvancedCustomizationScreenState
    extends State<AdvancedCustomizationScreen> {
  // Preferências de visualização
  bool _showHourlyForecast = true;
  bool _showDailyForecast = true;
  bool _showWeatherDetails = true;
  bool _showUVIndex = true;
  bool _showAirQuality = true;
  bool _showSunriseSunset = true;
  bool _showPrecipitation = true;
  bool _showWindInfo = true;
  bool _showHumidity = true;
  bool _showPressure = true;
  bool _showVisibility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personalização Avançada',
          style: TextStyle(
            color: const Color(0xFF1E88E5),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Salvar preferências
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Preferências salvas!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Salvar',
              style: TextStyle(
                color: const Color(0xFF1E88E5),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        children: [
          _buildSectionTitle('Informações Principais'),
          _buildCustomizationCard([
            _buildSwitchItem(
              'Previsão por Hora',
              'Exibir previsão das próximas horas',
              _showHourlyForecast,
              (value) => setState(() => _showHourlyForecast = value),
            ),
            _buildSwitchItem(
              'Previsão Diária',
              'Exibir previsão dos próximos dias',
              _showDailyForecast,
              (value) => setState(() => _showDailyForecast = value),
            ),
            _buildSwitchItem(
              'Detalhes do Clima',
              'Exibir informações detalhadas',
              _showWeatherDetails,
              (value) => setState(() => _showWeatherDetails = value),
            ),
          ]),
          SizedBox(height: 2.h),
          _buildSectionTitle('Qualidade do Ar e Índices'),
          _buildCustomizationCard([
            _buildSwitchItem(
              'Índice UV',
              'Mostrar índice de radiação UV',
              _showUVIndex,
              (value) => setState(() => _showUVIndex = value),
            ),
            _buildSwitchItem(
              'Qualidade do Ar',
              'Exibir índice de qualidade do ar',
              _showAirQuality,
              (value) => setState(() => _showAirQuality = value),
            ),
          ]),
          SizedBox(height: 2.h),
          _buildSectionTitle('Informações Astronômicas'),
          _buildCustomizationCard([
            _buildSwitchItem(
              'Nascer/Pôr do Sol',
              'Mostrar horários do sol',
              _showSunriseSunset,
              (value) => setState(() => _showSunriseSunset = value),
            ),
          ]),
          SizedBox(height: 2.h),
          _buildSectionTitle('Dados Meteorológicos'),
          _buildCustomizationCard([
            _buildSwitchItem(
              'Precipitação',
              'Exibir probabilidade de chuva',
              _showPrecipitation,
              (value) => setState(() => _showPrecipitation = value),
            ),
            _buildSwitchItem(
              'Informações de Vento',
              'Mostrar velocidade e direção do vento',
              _showWindInfo,
              (value) => setState(() => _showWindInfo = value),
            ),
            _buildSwitchItem(
              'Umidade',
              'Exibir umidade relativa do ar',
              _showHumidity,
              (value) => setState(() => _showHumidity = value),
            ),
            _buildSwitchItem(
              'Pressão Atmosférica',
              'Mostrar pressão barométrica',
              _showPressure,
              (value) => setState(() => _showPressure = value),
            ),
            _buildSwitchItem(
              'Visibilidade',
              'Exibir distância de visibilidade',
              _showVisibility,
              (value) => setState(() => _showVisibility = value),
            ),
          ]),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomizationCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E88E5),
          ),
        ],
      ),
    );
  }
}
