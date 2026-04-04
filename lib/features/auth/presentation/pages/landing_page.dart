import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo Placeholder
              Center(child: Image.asset('assets/logo.png', width: 150, height: 150)),
              const SizedBox(height: 40),
              // Masuk Button
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54B7C2).withOpacity(0.1),
                  foregroundColor: Colors.black.withOpacity(0.5),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Masuk'),
              ),
              const SizedBox(height: 16),
              // Daftar Button
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54B7C2),
                  foregroundColor: Colors.black,
                  elevation: 5,
                  shadowColor: Colors.black45,
                ),
                child: const Text('Daftar'),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
