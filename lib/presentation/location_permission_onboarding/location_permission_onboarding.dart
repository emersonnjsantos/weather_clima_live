import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/app_export.dart';
import './widgets/location_permission_card_widget.dart';
import './widgets/permission_button_widget.dart';

class LocationPermissionOnboarding extends StatefulWidget {
  const LocationPermissionOnboarding({super.key});

  @override
  State<LocationPermissionOnboarding> createState() =>
      _LocationPermissionOnboardingState();
}

class _LocationPermissionOnboardingState
    extends State<LocationPermissionOnboarding> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleAllowLocationAccess() {
    HapticFeedback.lightImpact();
    // Simular solicitação de permissão e navegação
    _showPermissionDialog();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Column(
            children: [
              Icon(
                HugeIcons.strokeRoundedGoogleMaps,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Para que necessitamos da sua localização?',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta aplicação utiliza a tua localização para fornecer previsões meteorológicas, avisos meteorológicos, temperatura na barra de notificações, widgets e notificações sobre eventos importantes para a sua localização actual.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              // Ilustração - Ícone móvel
              Container(
                height: 150,
                child: SvgPicture.asset(
                  'assets/images/mobile.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handlePermissionDenied();
              },
              child: Text(
                'Não, obrigado',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handlePermissionGranted();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePermissionGranted() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/weather-dashboard');
  }

  void _handlePermissionDenied() {
    Navigator.pushReplacementNamed(context, '/city-search');
  }

  void _handleSkipForNow() {
    Navigator.pushReplacementNamed(context, '/city-search');
  }

  void _handleBackPressed() {
    Navigator.pushReplacementNamed(context, '/city-search');
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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBackPressed();
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: SafeArea(
            bottom:
                false, // Permite que o conteúdo se estenda até a área de navegação
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 6.w,
                    right: 6.w,
                    top: 2.h,
                    bottom: MediaQuery.of(context).padding.bottom +
                        2.h, // Adiciona padding seguro no fundo
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),

                      // Conteúdo principal
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ícone de localização animado
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Círculo animado de fundo
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      width: 25.w,
                                      height: 25.w,
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Ícone GPS SVG com efeito pulse
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: SvgPicture.asset(
                                      'assets/images/gps.svg',
                                      width: 24.w,
                                      height: 24.w,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),

                          // Título
                          Text(
                            'Obtenha o clima da sua localização',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),

                          // Descrição
                          Text(
                            'Permita o acesso à localização para receber atualizações automáticas do tempo e previsões precisas para onde você está agora.',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3.h),

                          // Cartão de permissão de localização
                          LocationPermissionCardWidget(),
                          SizedBox(height: 3.h),

                          // Nota de privacidade
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'security',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 5.w,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    'Seus dados de localização são usados apenas para fornecer previsões meteorológicas precisas.',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Botões de ação
                      Column(
                        children: [
                          PermissionButtonWidget(
                            text: 'Permitir Acesso à Localização',
                            onPressed: _handleAllowLocationAccess,
                            isPrimary: true,
                          ),
                          SizedBox(height: 2.h),
                          PermissionButtonWidget(
                            text: 'Pular por Agora',
                            onPressed: _handleSkipForNow,
                            isPrimary: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
