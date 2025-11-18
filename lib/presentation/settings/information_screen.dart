import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
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
          'Informação',
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
          // Privacidade e anúncios
          _buildInfoCard(
            icon: Icons.privacy_tip_outlined,
            iconColor: const Color(0xFF1E88E5),
            title: 'Privacidade e anúncios',
            subtitle: 'Configurar autorização',
            onTap: () {
              _showPrivacyDialog();
            },
          ),

          SizedBox(height: 1.5.h),

          // Sobre nós
          _buildInfoCard(
            icon: Icons.people_outline,
            iconColor: const Color(0xFF1E88E5),
            title: 'Sobre nós',
            subtitle: 'ClimaLive',
            onTap: () {
              _showAboutDialog();
            },
          ),

          SizedBox(height: 1.5.h),

          // FAQ e Ajuda
          _buildInfoCard(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF1E88E5),
            title: 'FAQ e Ajuda',
            subtitle: 'Sabia que...',
            onTap: () {
              _showFAQDialog();
            },
          ),

          SizedBox(height: 1.5.h),

          // Termos de uso
          _buildInfoCard(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF1E88E5),
            title: 'Termos de uso',
            subtitle: 'Política de Privacidade',
            onTap: () {
              _showTermsDialog();
            },
          ),

          SizedBox(height: 1.5.h),

          // Há algo errado?
          _buildInfoCard(
            icon: Icons.mail_outline,
            iconColor: const Color(0xFF1E88E5),
            title: 'Há algo errado?',
            subtitle: 'Envia-nos sua sugestão',
            onTap: () {
              _showFeedbackDialog();
            },
          ),

          SizedBox(height: 1.5.h),

          // Vote em mim 5 estrelas
          _buildInfoCard(
            icon: Icons.star_border,
            iconColor: const Color(0xFF1E88E5),
            title: 'Vote em mim 5 estrelas',
            subtitle: 'Você gostou do nosso aplicativo?',
            onTap: () {
              _showRatingDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.privacy_tip_outlined,
                  color: const Color(0xFF1E88E5), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Privacidade e Anúncios',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configurações de Privacidade',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'O ClimaLive respeita sua privacidade e está comprometido em proteger seus dados pessoais.',
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Você pode configurar:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildBulletPoint('Permissões de localização'),
                _buildBulletPoint('Anúncios personalizados'),
                _buildBulletPoint('Coleta de dados de uso'),
                _buildBulletPoint('Compartilhamento de dados'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.people_outline,
                  color: const Color(0xFF1E88E5), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Sobre Nós',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ClimaLive - Tempo 14 Dias',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Somos uma equipe dedicada a fornecer previsões meteorológicas precisas e confiáveis para você planejar seu dia com confiança.',
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Nosso aplicativo oferece:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildBulletPoint('Previsão de 14 dias'),
                _buildBulletPoint('Mapas meteorológicos em tempo real'),
                _buildBulletPoint('Alertas de condições severas'),
                _buildBulletPoint('Múltiplas localizações'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline,
                  color: const Color(0xFF1E88E5), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'FAQ e Ajuda',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFAQItem(
                  'Como atualizar a previsão?',
                  'Deslize para baixo na tela principal para atualizar.',
                ),
                _buildFAQItem(
                  'Como adicionar uma nova cidade?',
                  'Toque no ícone de busca e pesquise pela cidade desejada.',
                ),
                _buildFAQItem(
                  'A previsão não está atualizada?',
                  'Verifique sua conexão com a internet e as permissões de localização.',
                ),
                _buildFAQItem(
                  'Como alterar as unidades de medida?',
                  'Vá em Configurações > Unidades de medição.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline,
                  color: const Color(0xFF1E88E5), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Termos de Uso',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Política de Privacidade',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '1. Coleta de Dados',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Coletamos apenas dados necessários para fornecer previsões meteorológicas precisas.',
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  '2. Uso de Dados',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Seus dados são usados exclusivamente para melhorar sua experiência com o aplicativo.',
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  '3. Compartilhamento',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Não compartilhamos seus dados pessoais com terceiros sem seu consentimento.',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.mail_outline,
                  color: const Color(0xFF1E88E5), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Enviar Sugestão',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sua opinião é muito importante para nós!',
                style: TextStyle(fontSize: 13.sp),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Escreva sua sugestão aqui...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.all(3.w),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Obrigado pelo seu feedback!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
              ),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: const Color(0xFFFFD700), size: 24),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Avaliar Aplicativo',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Você está gostando do ClimaLive?',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'Avalie-nos com 5 estrelas na loja de aplicativos!',
                style: TextStyle(fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: const Color(0xFFFFD700),
                    size: 40,
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Agora não'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Obrigado pela sua avaliação!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
              ),
              child: const Text('Avaliar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h, left: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 14.sp)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E88E5),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
