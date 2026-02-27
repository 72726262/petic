import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/features/admin/services/admin_service.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _service = AdminService();
  List<UserModel> _users = [];
  List<UserModel> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  String _roleFilter = 'all';

  final _roles = ['all', 'user', 'hr', 'it', 'admin'];
  final _roleLabels = {
    'all': 'الكل',
    'user': 'موظف',
    'hr': 'الموارد البشرية',
    'it': 'تقنية المعلومات',
    'admin': 'مدير'
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await _service.fetchAllUsers();
      setState(() {
        _users = users;
        _filtered = users;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _users.where((u) {
        final matchSearch =
            _searchQuery.isEmpty || u.fullName.contains(_searchQuery) || u.email.contains(_searchQuery);
        final matchRole = _roleFilter == 'all' || u.role == _roleFilter;
        return matchSearch && matchRole;
      }).toList();
    });
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'hr':
        return AppColors.hrColor;
      case 'it':
        return AppColors.itColor;
      default:
        return AppColors.primary;
    }
  }

  String _roleLabel(String role) =>
      _roleLabels[role] ?? role;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة الموظفين',
        showBack: true,
      ),
      body: _loading
          ? const LoadingWidget()
          : Column(
              children: [
                // ── Search + Filter Bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (q) {
                          _searchQuery = q;
                          _applyFilter();
                        },
                        decoration: InputDecoration(
                          hintText: 'بحث عن موظف...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceVariantLight,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.lgBorderRadius,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Role filter chips
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _roles.map((r) {
                            final selected = _roleFilter == r;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(_roleLabel(r)),
                                selected: selected,
                                onSelected: (_) {
                                  _roleFilter = r;
                                  _applyFilter();
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                                checkmarkColor: AppColors.primary,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Employee List ──
                Expanded(
                  child: _filtered.isEmpty
                      ? const EmptyStateWidget(
                          title: 'لا يوجد موظفون',
                          icon: Icons.people_outline_rounded,
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (ctx, i) {
                              final user = _filtered[i];
                              return StaggeredListItem(
                                index: i,
                                child: PressEffect(
                                  onTap: () => context.push(
                                    RouteNames.adminEmployeeDetail.replaceAll(
                                        ':id', user.id),
                                  ),
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
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: _roleColor(user.role)
                                              .withOpacity(0.12),
                                          backgroundImage: user.avatarUrl != null
                                              ? NetworkImage(user.avatarUrl!)
                                              : null,
                                          child: user.avatarUrl == null
                                              ? Text(
                                                  user.initials,
                                                  style: AppTypography.titleSmall
                                                      .copyWith(
                                                          color: _roleColor(
                                                              user.role)),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(user.fullName,
                                                  style:
                                                      AppTypography.titleSmall),
                                              Text(user.email,
                                                  style: AppTypography.bodySmall
                                                      .copyWith(
                                                    color: isDark
                                                        ? AppColors
                                                            .onSurfaceVariantDark
                                                        : AppColors
                                                            .onSurfaceVariantLight,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _roleColor(user.role)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                AppRadius.fullBorderRadius,
                                          ),
                                          child: Text(
                                            _roleLabel(user.role),
                                            style:
                                                AppTypography.labelSmall.copyWith(
                                              color: _roleColor(user.role),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
