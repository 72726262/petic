import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/router/app_router.dart';
import 'package:employee_portal/core/theme/app_theme.dart';
import 'package:employee_portal/core/theme/theme_cubit.dart';
import 'package:employee_portal/core/locale/locale_cubit.dart';
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

  runApp(const EmployeePortalApp());
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
        // Locale — load saved preference at startup
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit()..loadLocale(),
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
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (ctx2, locale) {
              final isAr = locale.languageCode == 'ar';
              return MaterialApp.router(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('ar'), Locale('en')],
                locale: locale,
                routerConfig: AppRouter.router,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                builder: (context, child) {
                  return Directionality(
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    child: NotificationOverlayWrapper(child: child!),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
