import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ErrorViewWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorViewWidget({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          SizedBox(height: 2.h),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}
