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
                'Login', // Defaulting to Login title as per top-left screenshot, though this might need to be dynamic or just "Welcome"
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.grey[700], // Dark grey text
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Logo Placeholder
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9), // Light grey placeholder
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Logo',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Masuk Button
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF757575), // Dark grey
                  elevation: 5,
                  shadowColor: Colors.black45,
                ),
                child: const Text('Masuk'),
              ),
              const SizedBox(height: 16),
              // Daftar Button
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E0E0), // Light grey
                  foregroundColor: Colors.black54, // Dark text
                  elevation: 5,
                  shadowColor: Colors.black26,
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
