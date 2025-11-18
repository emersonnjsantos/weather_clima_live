import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Premium',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 10.h,
              ),
              child: Column(
                children: [
                  // Imagem ilustrativa
                  Container(
                    width: double.infinity,
                    height: 35.h,
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/images/Photo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.diamond,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Premium',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Aproveite o tempo sem\npublicidade',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Título
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      'Aproveite o tempo sem publicidade',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Lista de benefícios
                  _buildBenefitItem(
                    text: 'Confira nossas previsões sem anúncios.',
                  ),
                  _buildBenefitItem(
                    text: 'Radar 24 horas',
                  ),
                  _buildBenefitItem(
                    text: 'Escolha quais componentes você quer e...',
                  ),
                  _buildBenefitItem(
                    text: 'Damos prioridade aos seus comentários...',
                  ),
                  _buildBenefitItem(
                    text: 'Confira nossas camadas exclusivas de...',
                  ),
                  _buildBenefitItem(
                    text: 'Amamos clientes Premium',
                  ),
                  _buildBenefitItem(
                    text: 'Tema Premium ClimaLive',
                  ),

                  SizedBox(height: 3.h),

                  // Período de teste
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(42),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/diamond.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Período de teste: 6 dias',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Botão Anual
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showPurchaseDialog(
                                  context, 'Anual', 'R\$ 44,99/ano');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 2.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(42),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Anual: R\$ 44,99',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '/ano',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Badge de economia
                        Positioned(
                          top: -8,
                          right: 4.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Economize 53%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Botão Mensal
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showPurchaseDialog(context, 'Mensal', 'R\$ 7,99/mês');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[800],
                        side: BorderSide(color: Colors.blue[800]!, width: 2),
                        padding: EdgeInsets.symmetric(vertical: 2.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mensal: R\$ 7,99',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/mês',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 5.h),

                  // Texto de termos
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      'Durante o período experimental não será cobrado e a sua assinatura só será ativada se cancelar 24 horas antes do período experimental expirar. Lembre-se de que a renovação da sua assinatura será automática no final da sua conta na Play Store / App Store, ou a sua subscrição será cancelada a partir da web. O cancelamento deve ser feito 24 horas antes da data de renovação. Todas as compras de assinatura não são parciais. Não pagamentos de subscrição através da Play Store ou App Store no momento da confirmação da compra. Gerencie sua assinatura através da nossa Política de Privacidade e Termos de uso',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Links de política
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Abrir política de privacidade
                        },
                        child: Text(
                          'Política de Privacidade',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' e ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Abrir termos de uso
                        },
                        child: Text(
                          'Termos de uso',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue[700],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/diamond.svg',
            width: 20,
            height: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String plan, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assinar $plan'),
        content: Text(
          'Você será redirecionado para a Play Store/App Store para concluir a assinatura $plan por $price.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aqui você implementaria a integração com a loja (in-app purchase)
              // Por enquanto, apenas mostra uma mensagem
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Funcionalidade de compra em desenvolvimento'),
                  backgroundColor: Colors.blue[700],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
