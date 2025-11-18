import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/weather_api_service.dart';

class IconManagerScreen extends StatefulWidget {
  const IconManagerScreen({super.key});

  @override
  State<IconManagerScreen> createState() => _IconManagerScreenState();
}

class _IconManagerScreenState extends State<IconManagerScreen> {
  final weatherService = WeatherApiService();

  // Mapa de códigos de ícones da OpenWeatherMap
  final Map<String, Map<String, dynamic>> _weatherIcons = {
    '01d': {
      'name': 'Céu Limpo (Dia)',
      'description': 'Céu claro durante o dia',
      'color': Colors.orange,
    },
    '01n': {
      'name': 'Céu Limpo (Noite)',
      'description': 'Céu claro durante a noite',
      'color': Colors.indigo,
    },
    '02d': {
      'name': 'Poucas Nuvens (Dia)',
      'description': 'Parcialmente nublado durante o dia',
      'color': Colors.amber,
    },
    '02n': {
      'name': 'Poucas Nuvens (Noite)',
      'description': 'Parcialmente nublado durante a noite',
      'color': Colors.blueGrey,
    },
    '03d': {
      'name': 'Nuvens Esparsas (Dia)',
      'description': 'Nuvens dispersas',
      'color': Colors.grey,
    },
    '03n': {
      'name': 'Nuvens Esparsas (Noite)',
      'description': 'Nuvens dispersas à noite',
      'color': Colors.grey[700]!,
    },
    '04d': {
      'name': 'Nublado',
      'description': 'Céu nublado',
      'color': Colors.blueGrey,
    },
    '04n': {
      'name': 'Nublado (Noite)',
      'description': 'Céu nublado à noite',
      'color': Colors.blueGrey[800]!,
    },
    '09d': {
      'name': 'Chuva Forte',
      'description': 'Chuva intensa',
      'color': Colors.blue[700]!,
    },
    '09n': {
      'name': 'Chuva Forte (Noite)',
      'description': 'Chuva intensa à noite',
      'color': Colors.blue[900]!,
    },
    '10d': {
      'name': 'Chuva (Dia)',
      'description': 'Chuva durante o dia',
      'color': Colors.blue,
    },
    '10n': {
      'name': 'Chuva (Noite)',
      'description': 'Chuva durante a noite',
      'color': Colors.blue[800]!,
    },
    '11d': {
      'name': 'Tempestade',
      'description': 'Tempestade com raios',
      'color': Colors.purple,
    },
    '11n': {
      'name': 'Tempestade (Noite)',
      'description': 'Tempestade à noite',
      'color': Colors.purple[900]!,
    },
    '13d': {
      'name': 'Neve (Dia)',
      'description': 'Neve durante o dia',
      'color': Colors.lightBlue,
    },
    '13n': {
      'name': 'Neve (Noite)',
      'description': 'Neve durante a noite',
      'color': Colors.lightBlue[700]!,
    },
    '50d': {
      'name': 'Neblina/Névoa (Dia)',
      'description': 'Condições de baixa visibilidade',
      'color': Colors.blueGrey[300]!,
    },
    '50n': {
      'name': 'Neblina/Névoa (Noite)',
      'description': 'Condições de baixa visibilidade à noite',
      'color': Colors.blueGrey[600]!,
    },
  };

  String _selectedIcon = '01d';
  String _iconSize = '2x';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Gerenciador de Ícones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview do ícone selecionado
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(4.w),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _weatherIcons[_selectedIcon]!['color'] as Color,
                      (_weatherIcons[_selectedIcon]!['color'] as Color)
                          .withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Ícone grande
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Image.network(
                        weatherService.getWeatherIconUrl(_selectedIcon,
                            size: '4x'),
                        width: 30.w,
                        height: 30.w,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error_outline,
                            size: 30.w,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      _weatherIcons[_selectedIcon]!['name'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      _weatherIcons[_selectedIcon]!['description'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 2.h),

                    // Código do ícone
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Código: $_selectedIcon',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Seletor de tamanho
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamanho do Ícone',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      children: ['1x', '2x', '4x'].map((size) {
                        final isSelected = _iconSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _iconSize = size;
                              });
                            }
                          },
                          selectedColor: const Color(0xFF1976D2),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Lista de ícones disponíveis
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Ícones Disponíveis',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              // Grid de ícones
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _weatherIcons.length,
                  itemBuilder: (context, index) {
                    final iconCode = _weatherIcons.keys.elementAt(index);
                    final iconData = _weatherIcons[iconCode]!;
                    final isSelected = _selectedIcon == iconCode;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconCode;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1976D2)
                                : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ícone
                            Image.network(
                              weatherService.getWeatherIconUrl(iconCode,
                                  size: _iconSize),
                              width: 15.w,
                              height: 15.w,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error_outline,
                                  size: 15.w,
                                  color: Colors.red,
                                );
                              },
                            ),

                            SizedBox(height: 1.h),

                            // Nome
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: Text(
                                iconData['name'] as String,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF1976D2)
                                      : Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Código
                            Text(
                              iconCode,
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 4.h),

              // Informações adicionais
              Container(
                margin: EdgeInsets.all(4.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 24.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sobre os Ícones',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Ícones fornecidos pela API OpenWeatherMap. '
                            'Use esta tela para visualizar e testar todos os ícones disponíveis.',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.blue[800],
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
      ),
    );
  }
}
