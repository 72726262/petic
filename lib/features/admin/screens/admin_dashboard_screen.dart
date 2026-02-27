import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/utils/app_strings.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';
import 'package:employee_portal/features/admin/services/admin_service.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';

// ─── Data Models ────────────────────────────────────────────────────
class _AdminAction {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  const _AdminAction({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// ════════════════════════════════════════════════════════════════════
// ADMIN DASHBOARD SCREEN
// ════════════════════════════════════════════════════════════════════
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  AdminStats? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await _adminService.fetchStats();
    if (mounted)
      setState(() {
        _stats = s;
        _loadingStats = false;
      });
  }

  List<_AdminAction> _getActions(BuildContext context, UserModel user) {
    final s = AppStrings.of(context);
    final actions = <_AdminAction>[];
    if (user.isAdmin) {
      actions.add(_AdminAction(
        label: s.isAr ? 'إدارة الأخبار' : 'Manage News',
        subtitle: s.isAr ? 'إضافة وتعديل وحذف الأخبار' : 'Add, edit and delete news',
        icon: Icons.newspaper_outlined,
        color: AppColors.newsColor,
        route: RouteNames.adminManageNews,
      ));
      actions.add(_AdminAction(
        label: s.isAr ? 'إدارة الفعاليات' : 'Manage Events',
        subtitle: s.isAr ? 'إدارة الفعاليات والتصويتات' : 'Manage events and polls',
        icon: Icons.event_outlined,
        color: AppColors.eventsColor,
        route: RouteNames.adminManageEvents,
      ));
    }
    if (user.isHR) {
      actions.add(_AdminAction(
        label: s.manageHR,
        subtitle: s.isAr ? 'السياسات والتدريب والوظائف' : 'Policies, training and jobs',
        icon: Icons.people_outline_rounded,
        color: AppColors.hrColor,
        route: RouteNames.adminManageHR,
      ));
    }
    if (user.isIT) {
      actions.add(_AdminAction(
        label: s.manageIT,
        subtitle: s.isAr ? 'التنبيهات والأدلة والسياسات' : 'Alerts, guides and policies',
        icon: Icons.computer_outlined,
        color: AppColors.itColor,
        route: RouteNames.adminManageIT,
      ));
    }
    if (user.isAdmin || user.isHR) {
      actions.add(_AdminAction(
        label: s.isAr ? 'إنشاء حساب جديد' : 'Create New Account',
        subtitle: s.isAr ? 'إضافة موظف جديد للنظام' : 'Add a new employee to the system',
        icon: Icons.person_add_rounded,
        color: AppColors.success,
        route: RouteNames.signup,
      ));
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: s.adminDashboard,
        showBack: true,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final user = state.user;
          final actions = _getActions(context, user);

          return RefreshIndicator(
            onRefresh: _loadStats,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // ─── Stats (Admin Only) ───────────────────────────────
                if (user.isAdmin) ...[
                  FadeSlideUp(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.isAr ? 'نظرة عامة' : 'Overview',
                            style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        if (_loadingStats)
                          const Center(child: CircularProgressIndicator())
                        else
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            childAspectRatio: 2.0,
                            children: [
                              _LiveStatCard(
                                label: s.employees,
                                count: '${_stats?.usersCount ?? 0}',
                                icon: Icons.people_outline_rounded,
                                color: AppColors.primary,
                                onTap: () =>
                                    context.push(RouteNames.adminEmployees),
                              ),
                              _LiveStatCard(
                                label: s.news,
                                count: '${_stats?.newsCount ?? 0}',
                                icon: Icons.newspaper_outlined,
                                color: AppColors.newsColor,
                                onTap: () =>
                                    context.push(RouteNames.adminManageNews),
                              ),
                              _LiveStatCard(
                                label: s.events,
                                count: '${_stats?.eventsCount ?? 0}',
                                icon: Icons.event_outlined,
                                color: AppColors.eventsColor,
                                onTap: () =>
                                    context.push(RouteNames.adminManageEvents),
                              ),
                              _LiveStatCard(
                                label: s.settings,
                                count: '⚙',
                                icon: Icons.settings_outlined,
                                color: AppColors.secondary,
                                onTap: () =>
                                    context.push(RouteNames.adminEmployees),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // ─── Action Tiles ────────────────────────────────────
                Text(s.isAr ? 'إدارة المحتوى' : 'Content Management',
                    style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.md),

                ...actions.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: StaggeredListItem(
                          index: entry.key,
                          child: PressEffect(
                            onTap: () => context.push(entry.value.route),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
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
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          entry.value.color.withOpacity(0.12),
                                      borderRadius: AppRadius.mdBorderRadius,
                                    ),
                                    child: Icon(entry.value.icon,
                                        color: entry.value.color, size: 24),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.value.label,
                                            style: AppTypography.titleSmall),
                                        const SizedBox(height: 2),
                                        Text(
                                          entry.value.subtitle,
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: isDark
                                                ? AppColors.onSurfaceVariantDark
                                                : AppColors
                                                    .onSurfaceVariantLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_left_rounded,
                                      color: entry.value.color),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// LIVE STAT CARD (tappable)
// ════════════════════════════════════════════════════════════════════
class _LiveStatCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _LiveStatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: AppRadius.smBorderRadius,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(count,
                      style: AppTypography.titleMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      )),
                  Text(label,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariantLight,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded,
                color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
