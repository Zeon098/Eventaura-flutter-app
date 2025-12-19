import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GradientAppBar extends StatelessWidget {
  const GradientAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            '🔍 Explore Services',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
          titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        ),
      ),
    );
  }
}
