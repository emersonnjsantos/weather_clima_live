import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  String _loadingText = 'Inicializando...';
  double _progress = 0.0;

  // Mock initialization states
  final List<Map<String, dynamic>> _initializationSteps = [
    {'text': 'Verificando permissões...', 'duration': 1000},
    {'text': 'Carregando dados meteorológicos...', 'duration': 1200},
    {'text': 'Configurando localização...', 'duration': 1000},
    {'text': 'Preparando interface...', 'duration': 1200},
  ];

  @override
  void initState() {
    super.initState();
    // Ativar modo imersivo (ocultar controles de navegação)
    _setImmersiveMode();
    _setupAnimations();
    _startInitialization();
  }

  void _setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _startInitialization() async {
    await Future.delayed(const Duration(milliseconds: 800));

    for (int i = 0; i < _initializationSteps.length; i++) {
      if (mounted) {
        setState(() {
          _loadingText = _initializationSteps[i]['text'];
          _progress = (i + 1) / _initializationSteps.length;
        });
      }

      await Future.delayed(
        Duration(milliseconds: _initializationSteps[i]['duration']),
      );
    }

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Restaurar controles de navegação antes de sair da splash
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    // Sempre navega para a tela de permissão de localização
    Navigator.pushReplacementNamed(context, '/location-permission-onboarding');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildGradientBackground(),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildLogoSection(),
              ),
              Expanded(
                flex: 1,
                child: _buildLoadingSection(),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.lightTheme.primaryColor,
          AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          AppTheme.weatherClearLight,
          AppTheme.weatherClearLight.withValues(alpha: 0.6),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWeatherLogo(),
                  SizedBox(height: 3.h),
                  _buildAppTitle(),
                  SizedBox(height: 1.h),
                  _buildAppSubtitle(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherLogo() {
    return Container(
      width: 60.w,
      height: 60.w,
      child: Center(
        child: SvgPicture.asset(
          'assets/images/weather.svg',
          width: 60.w,
          height: 60.w,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      'ClimaLive',
      style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSubtitle() {
    return Text(
      'Previsão do tempo precisa',
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressIndicator(),
          SizedBox(height: 3.h),
          _buildLoadingText(),
          SizedBox(height: 2.h),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 60.w,
              height: 0.8.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1.h),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 60.w * _progress,
                    height: 0.8.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '${(_progress * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Versão 1.0.0',
      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.6),
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
