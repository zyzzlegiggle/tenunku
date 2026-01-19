import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

void main() {
  runApp(const TenunkuApp());
}

class TenunkuApp extends StatelessWidget {
  const TenunkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tenunku',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
