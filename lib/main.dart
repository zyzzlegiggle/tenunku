import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

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
