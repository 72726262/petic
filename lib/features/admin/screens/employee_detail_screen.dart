import 'package:flutter/material.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/utils/app_strings.dart';
import 'package:employee_portal/features/admin/services/admin_service.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:intl/intl.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String userId;
  const EmployeeDetailScreen({super.key, required this.userId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final _service = AdminService();
  UserModel? _user;
  bool _loading = true;
  String? _selectedRole;

  List<Map<String, String>> _roleItems(AppStrings s) => [
    {'value': 'user', 'label': s.roleUser},
    {'value': 'hr', 'label': s.roleHR},
    {'value': 'it', 'label': s.roleIT},
    {'value': 'admin', 'label': s.roleAdmin},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final users = await _service.fetchAllUsers();
    final found = users.where((u) => u.id == widget.userId).firstOrNull;
    if (mounted) {
      setState(() {
        _user = found;
        _selectedRole = found?.role ?? 'user';
        _loading = false;
      });
    }
  }

  Future<void> _updateRole() async {
    if (_selectedRole == null || _user == null) return;
    try {
      await _service.updateUserRole(userId: _user!.id, role: _selectedRole!);
      if (mounted) {
        ErrorHandler.showSuccessSnackbar(
            context, AppStrings.of(context).isAr ? 'تم تحديث الصلاحية بنجاح.' : 'Role updated successfully.');
        setState(() => _user = UserModel(
              id: _user!.id,
              email: _user!.email,
              fullName: _user!.fullName,
              role: _selectedRole!,
              department: _user!.department,
              avatarUrl: _user!.avatarUrl,
              createdAt: _user!.createdAt,
            ));
      }
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackbar(context, AppStrings.of(context).isAr ? 'فشل تحديث الصلاحية.' : 'Failed to update role.');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final s = AppStrings.of(ctx);
        return AlertDialog(
          title: Text(s.isAr ? 'حذف الموظف' : 'Delete Employee'),
          content: Text(s.isAr ? 'هل تريد حذف ${_user?.fullName}؟ لا يمكن التراجع.' : 'Delete ${_user?.fullName}? This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(s.cancel)),
            TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(s.delete)),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      try {
        await _service.deleteUser(_user!.id);
        if (mounted) Navigator.of(context).pop();
      } catch (_) {
        if (mounted) ErrorHandler.showErrorSnackbar(context, AppStrings.of(context).isAr ? 'فشل حذف الموظف.' : 'Failed to delete employee.');
      }
    }
  }

  Color _roleColor(String r) {
    switch (r) {
      case 'admin': return AppColors.error;
      case 'hr': return AppColors.hrColor;
      case 'it': return AppColors.itColor;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final s = AppStrings.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: s.isAr ? 'بيانات الموظف' : 'Employee Details',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: s.isAr ? 'حذف الموظف' : 'Delete Employee',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _user == null
              ? Center(child: Text(s.isAr ? 'لم يتم العثور على الموظف.' : 'Employee not found.'))
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // ── Avatar + Name ──
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor:
                                _roleColor(_user!.role).withOpacity(0.12),
                            backgroundImage: _user!.avatarUrl != null
                                ? NetworkImage(_user!.avatarUrl!)
                                : null,
                            child: _user!.avatarUrl == null
                                ? Text(_user!.initials,
                                    style: AppTypography.headlineMedium.copyWith(
                                        color: _roleColor(_user!.role)))
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(_user!.fullName,
                              style: AppTypography.headlineSmall),
                          const SizedBox(height: 4),
                          Text(_user!.email,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariantLight,
                              )),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _roleColor(_user!.role).withOpacity(0.1),
                              borderRadius: AppRadius.fullBorderRadius,
                            ),
                            child: Text(
                              _user!.role,
                              style: AppTypography.labelMedium.copyWith(
                                color: _roleColor(_user!.role),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Info Cards ──
                    _InfoRow(
                      label: s.departmentLabel,
                      value: _user!.department ?? s.notSpecified,
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      label: s.isAr ? 'تاريخ الانضمام' : 'Join Date',
                      value: DateFormat('dd MMM yyyy', s.isAr ? 'ar' : 'en')
                          .format(_user!.createdAt),
                      icon: Icons.calendar_today_outlined,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Role Management ──
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: AppRadius.lgBorderRadius,
                        boxShadow:
                            isDark ? AppShadows.softDark : AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.isAr ? 'تغيير الصلاحية' : 'Change Role',
                              style: AppTypography.titleSmall),
                          const SizedBox(height: AppSpacing.md),
                          ..._roleItems(s).map(
                            (r) => RadioListTile<String>(
                              value: r['value']!,
                              groupValue: _selectedRole,
                              onChanged: (v) =>
                                  setState(() => _selectedRole = v),
                              title: Text(r['label']!,
                                  style: AppTypography.bodyMedium),
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            onPressed: _updateRole,
                            label: s.saveChanges,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
      ),
      child: Row(
        children: [
          Icon(icon,
              color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight,
                  )),
              Text(value, style: AppTypography.titleSmall),
            ],
          ),
        ],
      ),
    );
  }
}
