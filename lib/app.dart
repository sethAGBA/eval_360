import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget racine de l'application EVAL360
class Eval360App extends StatelessWidget {
  const Eval360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EVAL360',
      debugShowCheckedModeBanner: false,

      // Thème
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing
      routerConfig: appRouter,
    );
  }
}
