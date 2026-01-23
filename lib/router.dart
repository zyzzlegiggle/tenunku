import 'package:go_router/go_router.dart';
import 'features/auth/presentation/pages/landing_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/pages/seller_home_page.dart';
import 'features/home/presentation/pages/edit_profile_page.dart';
import 'features/home/presentation/pages/settings/seller_settings_page.dart';
import 'features/home/presentation/pages/settings/account_security_page.dart';
import 'features/home/presentation/pages/settings/change_password_page.dart';
import 'features/home/presentation/pages/settings/my_address_page.dart';
import 'features/home/presentation/pages/settings/help_center_page.dart';
import 'features/home/presentation/pages/settings/help_answer_page.dart';
import 'features/home/presentation/pages/settings/notifications_page.dart';
import 'features/home/presentation/pages/settings/buyer_settings_page.dart';
import 'features/home/presentation/pages/settings/buyer_account_security_page.dart';
import 'features/home/presentation/pages/settings/buyer_address_page.dart';
import 'features/home/presentation/pages/settings/language_settings_page.dart';
import 'features/home/presentation/pages/settings/buyer_help_center_page.dart';
import 'features/home/presentation/pages/settings/buyer_help_answer_page.dart';
import 'features/auth/presentation/pages/seller_setup_page.dart';
import 'features/home/presentation/pages/seller_product_detail_page.dart';
import 'features/home/presentation/pages/add_product_page.dart';
import 'features/home/presentation/pages/buyer_account_page.dart';
import 'features/home/presentation/pages/buyer_edit_profile_page.dart';
import 'features/home/presentation/pages/favorites_page.dart';
import 'features/home/presentation/pages/buy_again_page.dart';
import 'features/home/presentation/pages/recently_viewed_page.dart';
import 'features/home/presentation/pages/submit_review_page.dart';
import 'features/home/data/models/product_model.dart';

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
    GoRoute(
      path: '/seller/settings',
      builder: (context, state) => const SellerSettingsPage(),
      routes: [
        GoRoute(
          path: 'account-security',
          builder: (context, state) => const AccountSecurityPage(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => const ChangePasswordPage(),
        ),
        GoRoute(
          path: 'address',
          builder: (context, state) => const MyAddressPage(),
        ),
        GoRoute(
          path: 'help-center',
          builder: (context, state) => const HelpCenterPage(),
          routes: [
            GoRoute(
              path: 'answer',
              builder: (context, state) => const HelpAnswerPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/seller-setup',
      builder: (context, state) => const SellerSetupPage(),
    ),
    GoRoute(
      path: '/seller/product/detail',
      builder: (context, state) {
        final product = state.extra as Product;
        return SellerProductDetailPage(product: product);
      },
    ),
    GoRoute(
      path: '/seller/product/add',
      builder: (context, state) => const AddProductPage(),
    ),
    // Buyer Account Routes
    GoRoute(
      path: '/buyer/account',
      builder: (context, state) => const BuyerAccountPage(),
    ),
    GoRoute(
      path: '/buyer/edit-profile',
      builder: (context, state) => const BuyerEditProfilePage(),
    ),
    GoRoute(
      path: '/buyer/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/buyer/buy-again',
      builder: (context, state) => const BuyAgainPage(),
    ),
    GoRoute(
      path: '/buyer/recently-viewed',
      builder: (context, state) => const RecentlyViewedPage(),
    ),
    GoRoute(
      path: '/buyer/submit-review',
      builder: (context, state) => const SubmitReviewPage(),
    ),
    // Buyer Settings Routes
    GoRoute(
      path: '/buyer/settings',
      builder: (context, state) => const BuyerSettingsPage(),
      routes: [
        GoRoute(
          path: 'account-security',
          builder: (context, state) => const BuyerAccountSecurityPage(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) =>
              const ChangePasswordPage(), // Reuse existing
        ),
        GoRoute(
          path: 'address',
          builder: (context, state) => const BuyerAddressPage(),
        ),
        GoRoute(
          path: 'language',
          builder: (context, state) => const LanguageSettingsPage(),
        ),
        GoRoute(
          path: 'help-center',
          builder: (context, state) => const BuyerHelpCenterPage(),
          routes: [
            GoRoute(
              path: 'answer',
              builder: (context, state) => const BuyerHelpAnswerPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
