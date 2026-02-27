import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class _NotifItem {
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color color;
  final String? route;

  const _NotifItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.route,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_NotifItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final client = Supabase.instance.client;
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated
        ? authState.user.isAdmin
        : false;

    final items = <_NotifItem>[];

    try {
      // ── Latest news ────────────────────────────────────────────────
      final news = await client
          .from(AppConstants.newsTable)
          .select('id, title, created_at')
          .order('created_at', ascending: false)
          .limit(5);
      for (final n in news as List) {
        items.add(_NotifItem(
          title: 'خبر جديد',
          body: n['title'] as String,
          time: DateTime.parse(n['created_at'] as String),
          icon: Icons.newspaper_outlined,
          color: AppColors.newsColor,
          route: '${RouteNames.newsList}/${n['id']}',
        ));
      }

      // ── Latest events ──────────────────────────────────────────────
      final events = await client
          .from(AppConstants.eventsTable)
          .select('id, title, created_at')
          .order('created_at', ascending: false)
          .limit(5);
      for (final e in events as List) {
        items.add(_NotifItem(
          title: 'فعالية جديدة',
          body: e['title'] as String,
          time: DateTime.parse(e['created_at'] as String),
          icon: Icons.event_outlined,
          color: AppColors.eventsColor,
          route: '${RouteNames.eventsList}/${e['id']}',
        ));
      }

      // ── HR Content (all users) ─────────────────────────────────────
      final hrItems = await client
          .from(AppConstants.hrContentTable)
          .select('id, title, description, created_at')
          .order('created_at', ascending: false)
          .limit(5);
      for (final h in hrItems as List) {
        items.add(_NotifItem(
          title: '📢 الموارد البشرية',
          body: h['title'] as String,
          time: DateTime.parse(h['created_at'] as String),
          icon: Icons.campaign_rounded,
          color: AppColors.hrColor,
          route: RouteNames.hr,
        ));
      }

      // ── IT Content (all users) ─────────────────────────────────────
      final itItems = await client
          .from(AppConstants.itContentTable)
          .select('id, title, created_at')
          .order('created_at', ascending: false)
          .limit(5);
      for (final it in itItems as List) {
        items.add(_NotifItem(
          title: '💻 تقنية المعلومات',
          body: it['title'] as String,
          time: DateTime.parse(it['created_at'] as String),
          icon: Icons.computer_rounded,
          color: AppColors.itColor,
          route: RouteNames.it,
        ));
      }

      // ── Mood activity (admin only) ─────────────────────────────────
      if (isAdmin) {
        final moods = await client
            .from(AppConstants.moodsTable)
            .select('mood, created_at, users(full_name)')
            .order('created_at', ascending: false)
            .limit(5);
        for (final m in moods as List) {
          final name = (m['users'] as Map?)?['full_name'] ?? 'موظف';
          final mood = m['mood'] as String? ?? '😐';
          items.add(_NotifItem(
            title: 'نشاط موظف',
            body: '$name سجّل مزاجه: $mood',
            time: DateTime.parse(m['created_at'] as String),
            icon: Icons.mood_outlined,
            color: AppColors.secondary,
          ));
        }
      }
    } catch (_) {}

    // Sort all by time desc
    items.sort((a, b) => b.time.compareTo(a.time));

    if (mounted) setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الإشعارات',
        showBack: true,
      ),
      body: _loading
          ? const LoadingWidget()
          : _items.isEmpty
              ? const EmptyStateWidget(
                  title: 'لا توجد إشعارات',
                  icon: Icons.notifications_none_rounded,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (ctx, i) {
                      final item = _items[i];
                      return GestureDetector(
                        onTap: item.route != null
                            ? () => context.push(item.route!)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            borderRadius: AppRadius.lgBorderRadius,
                            boxShadow: isDark
                                ? AppShadows.softDark
                                : AppShadows.soft,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.12),
                                  borderRadius: AppRadius.mdBorderRadius,
                                ),
                                child:
                                    Icon(item.icon, color: item.color, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(item.title,
                                              style:
                                                  AppTypography.titleSmall),
                                        ),
                                        Text(
                                          timeago.format(item.time, locale: 'ar'),
                                          style: AppTypography.labelSmall.copyWith(
                                            color: isDark
                                                ? AppColors.onSurfaceVariantDark
                                                : AppColors.onSurfaceVariantLight,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.body,
                                      style: AppTypography.bodySmall.copyWith(
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
                              if (item.route != null)
                                Icon(Icons.chevron_left_rounded,
                                    color: item.color.withOpacity(0.5), size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
