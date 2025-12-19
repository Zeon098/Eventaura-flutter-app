import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching services...',
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
