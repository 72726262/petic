import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/router/app_router.dart';
import 'package:employee_portal/core/theme/app_theme.dart';
import 'package:employee_portal/core/theme/theme_cubit.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/services/auth_service.dart';
import 'package:employee_portal/features/home/cubit/home_cubit.dart';
import 'package:employee_portal/features/home/services/home_service.dart';
import 'package:employee_portal/features/notifications/widgets/notification_overlay_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── System UI Overlay ───────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ─── Lock to Portrait ────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── Initialize Supabase ─────────────────────────────────────────
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    debug: false,
  );
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const EmployeePortalApp(),
    ),
  );
  //runApp(const EmployeePortalApp());
}

class EmployeePortalApp extends StatelessWidget {
  const EmployeePortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme — load saved preference at startup
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit()..loadTheme(),
        ),
        // Auth
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authService: AuthService(),
          )..checkAuthStatus(),
        ),
        // Home
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            homeService: HomeService(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            // ─── Meta ─────────────────────────────────────────────────
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // ─── Localizations (required for Arabic date pickers) ──────
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            locale: const Locale('ar'),

            // ─── Router ───────────────────────────────────────────────
            routerConfig: AppRouter.router,

            // ─── Theme ────────────────────────────────────────────────
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,

            // ─── Directionality ───────────────────────────────────────
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: NotificationOverlayWrapper(
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
