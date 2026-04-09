import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/donm_splash_page.dart';
import '../../features/auth/presentation/pages/donm_login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';

import '../../features/home/presentation/pages/donm_home_final.dart';
import '../../features/orders/presentation/pages/create_order_page.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/order_tracking_page.dart';

import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';

import '../../features/kyc/presentation/pages/kyc_home_page.dart';
import '../../features/kyc/presentation/pages/upload_documents_page.dart';
import '../../features/kyc/presentation/pages/document_verification_page.dart';

import '../../features/payments/presentation/pages/wallet_page.dart';
import '../../features/payments/presentation/pages/add_payment_method_page.dart';
import '../../features/payments/presentation/pages/payment_history_page.dart';

import '../../features/delivery/presentation/pages/delivery_home_page.dart';
import '../../features/delivery/presentation/pages/delivery_orders_page.dart';
import '../../features/delivery/presentation/pages/delivery_map_page.dart';

import '../services/auth_service.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const DonMSplashPage(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const DonMLoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Main Navigation
      GoRoute(
        path: '/home',
        builder: (context, state) => const DonMHomeFinal(),
        routes: [
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrderListPage(),
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const CreateOrderPage(),
              ),
              GoRoute(
                path: '/:orderId',
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  return OrderDetailPage(orderId: orderId);
                },
                routes: [
                  GoRoute(
                    path: '/tracking',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      return OrderTrackingPage(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: '/edit',
                builder: (context, state) => const EditProfilePage(),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/kyc',
            builder: (context, state) => const KycHomePage(),
            routes: [
              GoRoute(
                path: '/upload',
                builder: (context, state) => const UploadDocumentsPage(),
              ),
              GoRoute(
                path: '/verification',
                builder: (context, state) => const DocumentVerificationPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletPage(),
            routes: [
              GoRoute(
                path: '/add-payment-method',
                builder: (context, state) => const AddPaymentMethodPage(),
              ),
              GoRoute(
                path: '/history',
                builder: (context, state) => const PaymentHistoryPage(),
              ),
            ],
          ),
        ],
      ),
      
      // Delivery Person Routes
      GoRoute(
        path: '/delivery',
        builder: (context, state) => const DeliveryHomePage(),
        routes: [
          GoRoute(
            path: '/orders',
            builder: (context, state) => const DeliveryOrdersPage(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const DeliveryMapPage(),
          ),
        ],
      ),
      
      // Error Route
      GoRoute(
        path: '/error',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text(state.extra?.toString() ?? 'An error occurred'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.location}'),
      ),
    ),
    redirect: (context, state) {
      // Handle authentication redirects
      final isAuthenticated = context.read<AuthBloc>().state is AuthAuthenticated;
      
      // Protected routes
      final protectedRoutes = ['/home', '/delivery'];
      final isProtectedRoute = protectedRoutes.any((route) => state.location.startsWith(route));
      
      if (!isAuthenticated && isProtectedRoute) {
        return '/login';
      }
      
      // Redirect authenticated users from auth pages
      final authRoutes = ['/login', '/register', '/forgot-password'];
      final isAuthRoute = authRoutes.any((route) => state.location.startsWith(route));
      
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );
}
