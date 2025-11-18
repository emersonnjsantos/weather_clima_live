import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _newsAndVideosHighlight = true;
  String _selectedTheme = 'Tema Anoitecer';
  String _selectedCountry = 'Brasil';
  String _selectedLanguage = 'Português (Brasil)';
  String _selectedAQIScale = 'ClimaLive AQI ©';

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
          'Perfil',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        children: [
          // Notícias e vídeos em destaque
          _buildSwitchCard(
            icon: Icons.article_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Notícias e vídeos em destaque',
            subtitle: 'Na sua tela de previsão',
            value: _newsAndVideosHighlight,
            onChanged: (value) {
              setState(() => _newsAndVideosHighlight = value);
            },
          ),

          SizedBox(height: 1.5.h),

          // Aparência
          _buildProfileCard(
            icon: Icons.palette_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Aparência',
            currentValue: _selectedTheme,
            onTap: () {
              _showThemeOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // País/região
          _buildProfileCard(
            icon: Icons.public,
            iconColor: const Color(0xFF1E88E5),
            title: 'País/região',
            currentValue: _selectedCountry,
            onTap: () {
              _showCountryOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // Línguas
          _buildProfileCard(
            icon: Icons.language,
            iconColor: const Color(0xFF1E88E5),
            title: 'Línguas',
            currentValue: _selectedLanguage,
            onTap: () {
              _showLanguageOptions();
            },
          ),

          SizedBox(height: 1.5.h),

          // Escala AQI
          _buildProfileCard(
            icon: Icons.bar_chart,
            iconColor: const Color(0xFF1E88E5),
            title: 'Escala AQI',
            currentValue: _selectedAQIScale,
            onTap: () {
              _showAQIScaleOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
            SizedBox(width: 4.w),
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
                      fontSize: 13.sp,
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
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.grey.withOpacity(0.2),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
              SizedBox(width: 4.w),
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
                      currentValue,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
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

  void _showThemeOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aparência',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Tema Anoitecer', _selectedTheme, (value) {
                setState(() => _selectedTheme = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Tema Claro', _selectedTheme, (value) {
                setState(() => _selectedTheme = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Tema Escuro', _selectedTheme, (value) {
                setState(() => _selectedTheme = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Automático', _selectedTheme, (value) {
                setState(() => _selectedTheme = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCountryOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'País/região',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Brasil', _selectedCountry, (value) {
                setState(() => _selectedCountry = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Portugal', _selectedCountry, (value) {
                setState(() => _selectedCountry = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Estados Unidos', _selectedCountry, (value) {
                setState(() => _selectedCountry = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Línguas',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('Português (Brasil)', _selectedLanguage,
                  (value) {
                setState(() => _selectedLanguage = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Português (Portugal)', _selectedLanguage,
                  (value) {
                setState(() => _selectedLanguage = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('English (US)', _selectedLanguage, (value) {
                setState(() => _selectedLanguage = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('Español', _selectedLanguage, (value) {
                setState(() => _selectedLanguage = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAQIScaleOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Escala AQI',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile('ClimaLive AQI ©', _selectedAQIScale, (value) {
                setState(() => _selectedAQIScale = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('US EPA AQI', _selectedAQIScale, (value) {
                setState(() => _selectedAQIScale = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('China AQI', _selectedAQIScale, (value) {
                setState(() => _selectedAQIScale = value);
                Navigator.pop(context);
              }),
              _buildOptionTile('India AQI', _selectedAQIScale, (value) {
                setState(() => _selectedAQIScale = value);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
      String label, String currentValue, Function(String) onSelected) {
    final isSelected = label == currentValue;
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: currentValue,
      activeColor: const Color(0xFF1E88E5),
      selected: isSelected,
      onChanged: (value) {
        if (value != null) {
          onSelected(value);
        }
      },
    );
  }
}
