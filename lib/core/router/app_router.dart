import 'package:employee_portal/features/hr/screens/hr_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/router/go_router_refresh_stream.dart';

// Feature screens imports
import 'package:employee_portal/features/auth/screens/login_screen.dart';
import 'package:employee_portal/features/auth/screens/signup_screen.dart';
import 'package:employee_portal/features/auth/screens/forgot_password_screen.dart';
import 'package:employee_portal/features/splash/splash_screen.dart';
import 'package:employee_portal/features/home/screens/home_screen.dart';
import 'package:employee_portal/features/news/screens/news_list_screen.dart';
import 'package:employee_portal/features/news/screens/news_detail_screen.dart';
import 'package:employee_portal/features/news/screens/add_edit_news_screen.dart';
import 'package:employee_portal/features/events/screens/events_list_screen.dart';
import 'package:employee_portal/features/events/screens/event_detail_screen.dart';

import 'package:employee_portal/features/it/screens/it_screen.dart';
import 'package:employee_portal/features/mood/screens/mood_screen.dart';
import 'package:employee_portal/features/chatbot/screens/chatbot_screen.dart';
import 'package:employee_portal/features/admin/screens/admin_dashboard_screen.dart';
import 'package:employee_portal/features/admin/screens/manage_news_screen.dart';
import 'package:employee_portal/features/admin/screens/manage_events_screen.dart';
import 'package:employee_portal/features/admin/screens/manage_hr_screen.dart';
import 'package:employee_portal/features/admin/screens/manage_it_screen.dart';
import 'package:employee_portal/features/admin/screens/employees_screen.dart';
import 'package:employee_portal/features/admin/screens/employee_detail_screen.dart';
import 'package:employee_portal/features/profile/screens/profile_screen.dart';
import 'package:employee_portal/features/notifications/screens/notifications_screen.dart';

/// Centralized GoRouter configuration with animated transitions
class AppRouter {
  AppRouter._();

  /// Public routes that don't require authentication
  static const _publicRoutes = [
    RouteNames.splash,
    RouteNames.login,
    RouteNames.forgotPassword,
  ];

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;

      // Not logged in → if trying to reach a protected route, go to login
      if (!isLoggedIn &&
          loc != RouteNames.splash &&
          loc != RouteNames.login &&
          loc != RouteNames.forgotPassword) {
        return RouteNames.login;
      }
      // Already logged in → redirect away from login; let splash handle itself
      if (isLoggedIn && loc == RouteNames.login) {
        return RouteNames.home;
      }

      // Signup route → only admin and HR are allowed
      if (isLoggedIn && loc == RouteNames.signup) {
        final user = Supabase.instance.client.auth.currentUser;
        // We can't check role here easily, so we guard in the screen itself.
        // The route stays authenticated-only (not in public routes).
      }

      return null; // no redirect needed
    },
    routes: [
      // ─── Splash ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: AppPageTransitions.fadeTransition,
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      // ─── Auth ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: AppPageTransitions.fadeSlideUp,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: AppPageTransitions.fadeSlideUp,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: AppPageTransitions.fadeSlideUp,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      // ─── Home ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: AppPageTransitions.fadeSlideUp,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      // ─── News ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.newsList,
        name: 'newsList',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NewsListScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 350),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'addNews',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AddEditNewsScreen(),
              transitionsBuilder: AppPageTransitions.slideFromBottom,
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'editNews',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: AddEditNewsScreen(
                newsId: state.pathParameters['id'],
              ),
              transitionsBuilder: AppPageTransitions.slideFromBottom,
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'newsDetail',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: NewsDetailScreen(
                newsId: state.pathParameters['id']!,
              ),
              transitionsBuilder: AppPageTransitions.fadeTransition,
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
        ],
      ),

      // ─── Events ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.eventsList,
        name: 'eventsList',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EventsListScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 350),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'eventDetail',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EventDetailScreen(
                eventId: state.pathParameters['id']!,
              ),
              transitionsBuilder: AppPageTransitions.fadeTransition,
              transitionDuration: const Duration(milliseconds: 350),
            ),
          ),
        ],
      ),

      // ─── HR ───────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.hr,
        name: 'hr',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HrScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // ─── IT ───────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.it,
        name: 'it',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ItScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // ─── Mood ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.mood,
        name: 'mood',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MoodScreen(),
          transitionsBuilder: AppPageTransitions.slideFromBottom,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // ─── Chatbot ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.chatbot,
        name: 'chatbot',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatbotScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // ─── Admin ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.adminDashboard,
        name: 'adminDashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
          transitionsBuilder: AppPageTransitions.scaleFade,
          transitionDuration: const Duration(milliseconds: 400),
        ),
        routes: [
          GoRoute(
            path: 'news',
            name: 'adminManageNews',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ManageNewsScreen(),
              transitionsBuilder: AppPageTransitions.slideFromRight,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          GoRoute(
            path: 'events',
            name: 'adminManageEvents',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ManageEventsScreen(),
              transitionsBuilder: AppPageTransitions.slideFromRight,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          GoRoute(
            path: 'hr',
            name: 'adminManageHR',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ManageHrScreen(),
              transitionsBuilder: AppPageTransitions.slideFromRight,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          GoRoute(
            path: 'it',
            name: 'adminManageIT',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ManageItScreen(),
              transitionsBuilder: AppPageTransitions.slideFromRight,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          GoRoute(
            path: 'employees',
            name: 'adminEmployees',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const EmployeesScreen(),
              transitionsBuilder: AppPageTransitions.slideFromRight,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
          GoRoute(
            path: 'employees/:id',
            name: 'adminEmployeeDetail',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: EmployeeDetailScreen(
                userId: state.pathParameters['id']!,
              ),
              transitionsBuilder: AppPageTransitions.slideFromRight,
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),

      // ─── Profile ─────────────────────────────────────────
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      // ─── Notifications ───────────────────────────────────────
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
          transitionsBuilder: AppPageTransitions.slideFromRight,
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
    ],

    // ─── Error Handler ──────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}
