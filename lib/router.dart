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
import 'features/home/presentation/pages/settings/buyer_notification_settings_page.dart';
import 'features/home/presentation/pages/settings/buyer_app_notifications_page.dart';
import 'features/home/presentation/pages/settings/buyer_email_notifications_page.dart';
import 'features/home/presentation/pages/settings/buyer_whatsapp_notifications_page.dart';
import 'features/auth/presentation/pages/seller_setup_page.dart';
import 'features/home/presentation/pages/seller_product_detail_page.dart';
import 'features/home/presentation/pages/product_detail_page.dart';
import 'features/home/presentation/pages/add_product_page.dart';
import 'features/home/presentation/pages/buyer_account_page.dart';
import 'features/home/presentation/pages/buyer_edit_profile_page.dart';
import 'features/home/presentation/pages/favorites_page.dart';
import 'features/home/presentation/pages/buy_again_page.dart';
import 'features/home/presentation/pages/recently_viewed_page.dart';
import 'features/home/presentation/pages/submit_review_page.dart';
import 'features/home/presentation/pages/payment_page.dart';
import 'features/home/presentation/pages/qris_payment_page.dart';
import 'features/home/presentation/pages/seller_biography_page.dart';
import 'features/home/presentation/pages/benang_membumi_page.dart';
import 'features/home/presentation/pages/warna_detail_page.dart';
import 'features/home/presentation/pages/pola_detail_page.dart';

import 'features/home/presentation/pages/seller_profile_detail_page.dart';
import 'features/home/presentation/pages/penggunaan_detail_page.dart';
import 'features/home/presentation/pages/untaian_tenunan_page.dart';
import 'features/home/data/models/product_model.dart';
import 'features/home/data/models/cart_item_model.dart';
import 'features/home/data/models/profile_model.dart';

import 'features/home/presentation/pages/buyer_chat_page.dart';
import 'features/home/presentation/pages/seller_chat_detail_page.dart';
import 'features/home/data/models/conversation_model.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final path = state.uri.path;
    final isAuthRoute =
        path == '/' ||
        path == '/login' ||
        path == '/register' ||
        path.startsWith('/otp');

    if (session != null && isAuthRoute) {
      final user = Supabase.instance.client.auth.currentUser;
      final role = user?.userMetadata?['role'] ?? 'pembeli';
      if (role == 'penjual') {
        return '/seller-home';
      } else {
        return '/buyer';
      }
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    // Benang Membumi Routes
    GoRoute(
      path: '/benang-membumi',
      builder: (context, state) => const BenangMembumiPage(),
    ),
    // Untaian Setiap Tenunan Route
    GoRoute(
      path: '/untaian-tenunan',
      builder: (context, state) => const UntaianTenunanPage(),
    ),
    GoRoute(
      path: '/benang-membumi/warna',
      builder: (context, state) {
        final colorData = state.extra as Map<String, dynamic>;
        return WarnaDetailPage(colorData: colorData);
      },
    ),
    GoRoute(
      path: '/benang-membumi/pola',
      builder: (context, state) {
        final polaData = state.extra as Map<String, String>;
        return PolaDetailPage(polaData: polaData);
      },
    ),
    GoRoute(
      path: '/benang-membumi/penggunaan',
      builder: (context, state) {
        final usageData = state.extra as Map<String, dynamic>;
        return PenggunaanDetailPage(usageData: usageData);
      },
    ),
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
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final initialIndex = state.extra is int ? state.extra as int : 0;
        return HomePage(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/buyer',
      builder: (context, state) {
        final initialIndex = state.extra is int ? state.extra as int : 0;
        return HomePage(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/buyer/payment',
      builder: (context, state) {
        final cartItems = state.extra as List<CartItem>;
        return PaymentPage(cartItems: cartItems);
      },
      routes: [
        GoRoute(
          path: 'qris',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            return QrisPaymentPage(
              totalAmount: args['totalAmount'] as double,
              qrisUrl: args['qrisUrl'] as String?,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/seller/biography',
      builder: (context, state) {
        final seller = state.extra as Profile;
        return SellerBiographyPage(seller: seller);
      },
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final seller = state.extra as Profile;
            return SellerProfileDetailPage(seller: seller);
          },
        ),
      ],
    ),
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
      path: '/product/detail',
      builder: (context, state) {
        final product = state.extra as Product;
        return ProductDetailPage(product: product);
      },
    ),
    GoRoute(
      path: '/seller/product/add',
      builder: (context, state) {
        final product = state.extra as Product?;
        return AddProductPage(product: product);
      },
    ),
    GoRoute(
      path: '/seller/chat/detail',
      builder: (context, state) {
        final conversation = state.extra as ConversationModel;
        return SellerChatDetailPage(conversation: conversation);
      },
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
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const BuyerNotificationSettingsPage(),
          routes: [
            GoRoute(
              path: 'app',
              builder: (context, state) => const BuyerAppNotificationsPage(),
            ),
            GoRoute(
              path: 'email',
              builder: (context, state) => const BuyerEmailNotificationsPage(),
            ),
            GoRoute(
              path: 'whatsapp',
              builder: (context, state) =>
                  const BuyerWhatsappNotificationsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/buyer/chat',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return BuyerChatPage(
          sellerId: extras['sellerId'],
          shopName: extras['shopName'],
          sellerAvatarUrl: extras['sellerAvatarUrl'],
        );
      },
    ),
  ],
);
