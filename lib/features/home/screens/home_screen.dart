import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';
import 'package:employee_portal/features/home/cubit/home_cubit.dart';
import 'package:employee_portal/features/home/cubit/home_state.dart';
import 'package:employee_portal/features/news/models/news_model.dart';
import 'package:employee_portal/features/events/models/event_model.dart';

import 'package:employee_portal/shared/widgets/app_card.dart';
import 'package:employee_portal/shared/widgets/section_header.dart';
import 'package:employee_portal/shared/widgets/grid_menu_item.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Try to load on init in case auth is already resolved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryLoadHome();
    });
  }

  void _tryLoadHome() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Only load if not already loaded or loading
      final homeState = context.read<HomeCubit>().state;
      if (homeState is HomeInitial) {
        context.read<HomeCubit>().loadHome(user: authState.user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Listens to auth state changes *after* the screen is built
      // This covers the case where auth resolves after navigation
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          final homeState = context.read<HomeCubit>().state;
          if (homeState is HomeInitial || homeState is HomeError) {
            context.read<HomeCubit>().loadHome(user: authState.user);
          }
        }
      },
      child: Scaffold(
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const _HomeSkeletonLoader();
            }
            if (state is HomeError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<HomeCubit>().loadHome(user: authState.user);
                  }
                },
              );
            }
            if (state is HomeLoaded) {
              return _HomeContent(
                data: state.data,
                user: state.user,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Main content when data is loaded
class _HomeContent extends StatelessWidget {
  final HomeData data;
  final UserModel user;

  const _HomeContent({required this.data, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeCubit>().refresh(user: user);
      },
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // ─── Section 1: Header / AppBar ───────────────────────────────
          SliverToBoxAdapter(
            child: _HomeHeader(user: user),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
          // ─── Section 2: Info Cards (Date + Weather) ───────────────────
          const SliverToBoxAdapter(
            child: _InfoCardsRow(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 5)),

          // ─── Section 3: Quick Actions Grid ────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'الوصول السريع',
              actionLabel: null,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: _QuickActionsGrid(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 5)),

          // ─── Section 4: CEO Message ───────────────────────────────────
          if (data.ceoMessageVisible && data.ceoMessage != null)
            SliverToBoxAdapter(
              child: _CeoMessageCard(message: data.ceoMessage!),
            ),

          // ─── Section 5: Latest News ───────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'آخر الأخبار',
              actionLabel: 'عرض الكل',
              onAction: () => context.push(RouteNames.newsList),
            ),
          ),
          SliverToBoxAdapter(
            child: data.latestNews.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: Text('لا توجد أخبار بعد')),
                  )
                : _NewsHorizontalList(news: data.latestNews),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // ─── Section 6: Events ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'الفعاليات القادمة',
              actionLabel: 'عرض الكل',
              onAction: () => context.push(RouteNames.eventsList),
            ),
          ),
          SliverToBoxAdapter(
            child: data.upcomingEvents.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: Text('لا توجد فعاليات قادمة')),
                  )
                : _EventsVerticalList(events: data.upcomingEvents),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // ─── Section 7: Mood Widget ───────────────────────────────────
          SliverToBoxAdapter(
            child: _MoodWidget(userId: user.id),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // ─── Section 8: Useful Links ──────────────────────────────────
          const SliverToBoxAdapter(child: _UsefulLinksSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 1: HOME HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _HomeHeader extends StatelessWidget {
  final UserModel user;

  const _HomeHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2236), Color(0xFF243047)],
              )
            : AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
          child: Row(
            children: [
              // Avatar
              _UserAvatar(user: user),

              const SizedBox(width: AppSpacing.md),

              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppUtils.getGreeting(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : 'الموظف',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.department != null)
                      Text(
                        user.department!,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),

              // Notification Bell
              _NotificationBell(),

              const SizedBox(width: AppSpacing.sm),

              // Admin icon (if user has any admin role)
              if (user.hasAdminAccess)
                GestureDetector(
                  onTap: () => context.push(RouteNames.adminDashboard),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_outlined, // More generic than domain admin
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserModel user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.profile),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: user.avatarUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl!,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  errorWidget: (_, __, ___) => _AvatarInitials(user: user),
                ),
              )
            : _AvatarInitials(user: user),
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final UserModel user;
  const _AvatarInitials({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        user.initials,
        style: AppTypography.titleSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.notifications),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '3',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 2: INFO CARDS
// ═══════════════════════════════════════════════════════════════════════════
class _InfoCardsRow extends StatefulWidget {
  const _InfoCardsRow();

  @override
  State<_InfoCardsRow> createState() => _InfoCardsRowState();
}

class _InfoCardsRowState extends State<_InfoCardsRow> {
  late DateTime _now;
  late Timer _timer;

  // Weather state
  String _temp = '--';
  String _condition = 'جارٍ التحميل...';
  String _cityName = '';
  IconData _weatherIcon = Icons.cloud_outlined;
  Color _weatherColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Tick every second for live clock
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _fetchWeather();
  }

  /// Get device location then fetch weather
  Future<void> _fetchWeather() async {
    try {
      // Request location permission gracefully
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      double lat = 24.7136; // fallback: Riyadh
      double lon = 46.6753;
      String cityName = 'الرياض';

      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 8),
          ),
        );
        lat = pos.latitude;
        lon = pos.longitude;
        // Reverse geocode via Open-Meteo geocoding
        cityName = await _reverseGeocode(lat, lon);
      }

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon&current_weather=true',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final cw = body['current_weather'] as Map<String, dynamic>;
        final temp = (cw['temperature'] as num).round();
        final code = cw['weathercode'] as int;
        if (mounted) {
          setState(() {
            _temp = '$temp°C';
            _condition = _label(code, cityName);
            _weatherIcon = _icon(code);
            _weatherColor = _color(code);
            _cityName = cityName;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _condition = 'الرياض');
    }
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search'
        '?name=${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}'
        '&count=1&language=ar&format=json',
      );
      // open-meteo geocoding doesn't support raw lat/lon reverse,
      // use nominatim instead (free, no key)
      final nomUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lon&format=json&accept-language=ar',
      );
      final res = await http.get(
        nomUrl,
        headers: {'User-Agent': 'EmployeePortalApp/1.0'},
      ).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final address = body['address'] as Map<String, dynamic>?;
        if (address != null) {
          return (address['city'] as String?) ??
              (address['town'] as String?) ??
              (address['village'] as String?) ??
              (address['state'] as String?) ??
              'موقعك الحالي';
        }
      }
    } catch (_) {}
    return 'موقعك الحالي';
  }

  String _label(int c, [String city = 'الرياض']) {
    if (c == 0) return 'مشمس صافٍ • $city';
    if (c <= 3) return 'غائم جزئياً • $city';
    if (c <= 48) return 'ضبابي • $city';
    if (c <= 67) return 'ممطر • $city';
    if (c <= 77) return 'ثلجي • $city';
    return 'عواصف رعدية • $city';
  }

  IconData _icon(int c) {
    if (c == 0) return Icons.wb_sunny_rounded;
    if (c <= 3) return Icons.wb_cloudy_outlined;
    if (c <= 48) return Icons.foggy;
    if (c <= 77) return Icons.ac_unit_rounded;
    return Icons.thunderstorm_outlined;
  }

  Color _color(int c) {
    if (c == 0) return AppColors.warning;
    if (c <= 3) return AppColors.secondary;
    return AppColors.primary;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            // ── Live Clock ──
            Expanded(
              child: _InfoCard(
                icon: Icons.access_time_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primaryContainer,
                title: DateFormat('hh:mm:ss a').format(_now),
                subtitle:
                    '${AppUtils.getDayInArabic()}، ${_now.day} ${AppUtils.getMonthInArabic(_now.month)} ${_now.year}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // ── Live Weather ──
            Expanded(
              child: _InfoCard(
                icon: _weatherIcon,
                iconColor: _weatherColor,
                iconBgColor: AppColors.warningLight,
                title: _temp,
                subtitle: _condition,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadius.smBorderRadius,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 3: QUICK ACTIONS GRID
// ═══════════════════════════════════════════════════════════════════════════
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionItem(
        label: 'الموارد البشرية',
        icon: Icons.people_alt_outlined,
        color: AppColors.hrColor,
        lightColor: AppColors.hrColorLight,
        route: RouteNames.hr,
      ),
      _QuickActionItem(
        label: 'تقنية المعلومات',
        icon: Icons.computer_outlined,
        color: AppColors.itColor,
        lightColor: AppColors.itColorLight,
        route: RouteNames.it,
      ),
      _QuickActionItem(
        label: 'الأخبار',
        icon: Icons.newspaper_outlined,
        color: AppColors.newsColor,
        lightColor: AppColors.newsColorLight,
        route: RouteNames.newsList,
      ),
      _QuickActionItem(
        label: 'الفعاليات',
        icon: Icons.event_outlined,
        color: AppColors.eventsColor,
        lightColor: AppColors.eventsColorLight,
        route: RouteNames.eventsList,
      ),
      _QuickActionItem(
        label: 'مزاجي',
        icon: Icons.sentiment_satisfied_outlined,
        color: AppColors.moodColor,
        lightColor: AppColors.moodColorLight,
        route: RouteNames.mood,
      ),
      _QuickActionItem(
        label: 'المساعد الذكي',
        icon: Icons.smart_toy_outlined,
        color: AppColors.chatbotColor,
        lightColor: AppColors.chatbotColorLight,
        route: RouteNames.chatbot,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GridMenuItem(
          label: item.label,
          icon: item.icon,
          color: item.color,
          lightColor: item.lightColor,
          animationIndex: index,
          onTap: () => context.push(item.route),
        );
      },
    );
  }
}

class _QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color lightColor;
  final String route;

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.route,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 4: CEO MESSAGE CARD
// ═══════════════════════════════════════════════════════════════════════════
class _CeoMessageCard extends StatelessWidget {
  final String message;

  const _CeoMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: GradientCard(
        gradient: AppColors.cardGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كلمة المدير العام',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'رسالة خاصة للموظفين',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 5: NEWS HORIZONTAL LIST
// ═══════════════════════════════════════════════════════════════════════════
class _NewsHorizontalList extends StatelessWidget {
  final List<NewsModel> news;

  const _NewsHorizontalList({required this.news});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: news.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = news[index];
          return _NewsHorizontalCard(
            news: item,
            onTap: () => context.push('${RouteNames.newsList}/${item.id}'),
          );
        },
      ),
    );
  }
}

class _NewsHorizontalCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;

  const _NewsHorizontalCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressEffect(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hero
            Hero(
              tag: 'news-image-${news.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: news.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: news.imageUrl!,
                        width: 200,
                        height: 120,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _NewsImagePlaceholder(),
                      )
                    : _NewsImagePlaceholder(),
              ),
            ),
            // Text
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatRelative(news.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 200,
      height: 120,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer,
      child: const Icon(Icons.newspaper_outlined,
          color: AppColors.primary, size: 36),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6: EVENTS VERTICAL LIST
// ═══════════════════════════════════════════════════════════════════════════
class _EventsVerticalList extends StatelessWidget {
  final List<EventModel> events;

  const _EventsVerticalList({required this.events});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: events
            .take(3)
            .toList()
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _EventCard(
                    key: ValueKey(e.value.id),
                    event: e.value,
                    index: e.key,
                    onTap: () =>
                        context.push('${RouteNames.eventsList}/${e.value.id}'),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final EventModel event;
  final int index;
  final VoidCallback onTap;

  const _EventCard(
      {super.key,
      required this.event,
      required this.index,
      required this.onTap});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.index * 80),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final event = widget.event;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: PressEffect(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppRadius.lgBorderRadius,
              boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
            ),
            child: Row(
              children: [
                // Date box
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: AppRadius.mdBorderRadius,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.date.day.toString(),
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        AppUtils.getMonthInArabic(event.date.month)
                            .substring(0, 3),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: isDark
                                  ? AppColors.onSurfaceVariantDark
                                  : AppColors.onSurfaceVariantLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.location!,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariantLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.onSurfaceVariantLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 7: MOOD WIDGET
// ═══════════════════════════════════════════════════════════════════════════
class _MoodWidget extends StatefulWidget {
  final String userId;

  const _MoodWidget({required this.userId});

  @override
  State<_MoodWidget> createState() => _MoodWidgetState();
}

class _MoodWidgetState extends State<_MoodWidget> {
  String? _selectedMood;
  bool _checking = true; // checking Supabase for today's entry
  bool _saving = false;
  bool _submittedToday = false;
  String? _errorMsg;

  final List<_MoodOption> _moods = const [
    _MoodOption(
        emoji: '😁',
        label: 'ممتاز',
        value: 'excellent',
        color: AppColors.moodExcellent),
    _MoodOption(
        emoji: '😊', label: 'جيد', value: 'good', color: AppColors.moodGood),
    _MoodOption(
        emoji: '😐',
        label: 'محايد',
        value: 'neutral',
        color: AppColors.moodNeutral),
    _MoodOption(
        emoji: '😔', label: 'سيئ', value: 'bad', color: AppColors.moodBad),
    _MoodOption(
        emoji: '😞',
        label: 'رديء',
        value: 'terrible',
        color: AppColors.moodTerrible),
  ];

  @override
  void initState() {
    super.initState();
    _checkTodayMood();
  }

  /// Checks Supabase: did this user already submit a mood today?
  Future<void> _checkTodayMood() async {
    try {
      final today = DateTime.now();
      final startOfDay =
          DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();

      final data = await Supabase.instance.client
          .from('moods')
          .select('id, mood')
          .eq('user_id', widget.userId)
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay)
          .limit(1);

      if (mounted) {
        final list = data as List;
        setState(() {
          _submittedToday = list.isNotEmpty;
          if (list.isNotEmpty) {
            _selectedMood = list.first['mood'] as String?;
          }
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _submitMood(String value) async {
    if (_saving || _submittedToday) return;
    setState(() {
      _saving = true;
      _selectedMood = value;
    });
    try {
      final today = DateTime.now();
      final startOfDay =
          DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();

      // Check if an entry already exists to avoid duplicates
      final existing = await Supabase.instance.client
          .from('moods')
          .select('id')
          .eq('user_id', widget.userId)
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay)
          .limit(1);

      if ((existing as List).isNotEmpty) {
        // Update existing
        await Supabase.instance.client
            .from('moods')
            .update({'mood': value}).eq('id', existing.first['id'] as String);
      } else {
        // Insert new
        await Supabase.instance.client.from('moods').insert({
          'user_id': widget.userId,
          'mood': value,
          'note': null,
        });
      }

      if (mounted)
        setState(() {
          _saving = false;
          _submittedToday = true;
        });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _selectedMood = null;
          _errorMsg = 'فشل حفظ مزاجك، حاول مرة أخرى';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
        ),
        child: _checking
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : _submittedToday
                ? _AlreadySubmittedBanner(selectedMood: _selectedMood)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كيف حالك اليوم؟',
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'شاركنا مزاجك وساعدنا في تحسين بيئة العمل',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(_errorMsg!,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.error)),
                        ),
                      _saving
                          ? const Center(
                              child: CircularProgressIndicator.adaptive())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _moods
                                  .map((mood) => _MoodButton(
                                        mood: mood,
                                        isSelected: _selectedMood == mood.value,
                                        onTap: () => _submitMood(mood.value),
                                      ))
                                  .toList(),
                            ),
                    ],
                  ),
      ),
    );
  }
}

/// Banner shown when the user already submitted their mood today
class _AlreadySubmittedBanner extends StatelessWidget {
  final String? selectedMood;
  const _AlreadySubmittedBanner({this.selectedMood});

  String _emoji(String? v) {
    const map = {
      'excellent': '😁',
      'good': '😊',
      'neutral': '😐',
      'bad': '😔',
      'terrible': '😞',
    };
    return map[v] ?? '😊';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_emoji(selectedMood), style: const TextStyle(fontSize: 40)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: AppRadius.fullBorderRadius,
          ),
          child: Text(
            '✓ تم تسجيل مزاجك اليوم',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'يمكنك تغيير مزاجك من تبويب مزاجي',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
        ),
      ],
    );
  }
}

class _MoodOption {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _MoodButton extends StatelessWidget {
  final _MoodOption mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 62,
        decoration: BoxDecoration(
          color: isSelected ? mood.color.withOpacity(0.15) : Colors.transparent,
          borderRadius: AppRadius.mdBorderRadius,
          border: isSelected
              ? Border.all(color: mood.color, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 4),
            Text(
              mood.label,
              style: AppTypography.labelSmall.copyWith(
                color:
                    isSelected ? mood.color : AppColors.onSurfaceVariantLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 8: USEFUL LINKS
// ═══════════════════════════════════════════════════════════════════════════
class _UsefulLinksSection extends StatelessWidget {
  const _UsefulLinksSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final links = [
      _LinkItem(
          label: 'الموقع الرسمي',
          icon: Icons.language_outlined,
          url: 'https://www.company.com'),
      _LinkItem(
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          url: 'mailto:info@company.com'),
      _LinkItem(
          label: 'نظام المهام',
          icon: Icons.task_outlined,
          url: 'https://tasks.company.com'),
      _LinkItem(
          label: 'التقارير',
          icon: Icons.bar_chart_outlined,
          url: 'https://reports.company.com'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'روابط مفيدة'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: links
                .map((link) => _LinkChip(link: link, isDark: isDark))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _LinkItem {
  final String label;
  final IconData icon;
  final String url;

  const _LinkItem({required this.label, required this.icon, required this.url});
}

class _LinkChip extends StatelessWidget {
  final _LinkItem link;
  final bool isDark;

  const _LinkChip({required this.link, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      onTap: () {
        // TODO: url_launcher
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.fullBorderRadius,
          boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(link.icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              link.label,
              style: AppTypography.labelMedium.copyWith(
                color:
                    isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOME SKELETON LOADER
// ═══════════════════════════════════════════════════════════════════════════
class _HomeSkeletonLoader extends StatelessWidget {
  const _HomeSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 140,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child:
                            SkeletonLoader(width: double.infinity, height: 80)),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            SkeletonLoader(width: double.infinity, height: 80)),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => SkeletonLoader(
                      width: double.infinity, height: double.infinity),
                ),
                const SizedBox(height: 24),
                SkeletonLoader(width: double.infinity, height: 100),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, __) => const HorizontalCardSkeleton(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
