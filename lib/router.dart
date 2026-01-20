import 'package:go_router/go_router.dart';
import 'features/auth/presentation/pages/landing_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/seller_home_page.dart';
import 'features/home/presentation/pages/edit_profile_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.extra as String;
        return OtpPage(email: email);
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/seller-home',
      builder: (context, state) => const SellerHomePage(),
    ),
    GoRoute(
      path: '/seller/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
  ],
);
