import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://eshvwuleojarvgddafqb.supabase.co',
    anonKey: 'sb_publishable_RJfvCXDhXBV4DxdpEbRPRw_mulwt6LS',
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
