import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
              const SizedBox(height: 20),
              Text(
                'Daftar',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Logo Placeholder
              Center(child: Image.asset('logo.png', width: 150, height: 150)),
              const Spacer(),
              // Masuk Button
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54B7C2).withOpacity(0.15),
                  foregroundColor: const Color(0xFF54B7C2),
                  elevation: 5,
                  shadowColor: Colors.black26,
                ),
                child: const Text('Masuk'),
              ),
              const SizedBox(height: 16),
              // Daftar Button
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF54B7C2),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.black45,
                ),
                child: const Text('Daftar'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
