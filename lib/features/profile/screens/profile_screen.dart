import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/theme/theme_cubit.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';

import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';

import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final uid = Supabase.instance.client.auth.currentUser!.id;
    try {
      await Supabase.instance.client.from('users').update({
        'full_name': _nameCtrl.text.trim(),
        'department': _deptCtrl.text.trim(),
      }).eq('id', uid);
      if (mounted) {
        context.read<AuthCubit>().refreshUser();
        ErrorHandler.showSuccessSnackbar(context, 'تم حفظ التغييرات بنجاح.');
        setState(() => _editing = false);
      }
    } catch (_) {
      if (mounted)
        ErrorHandler.showErrorSnackbar(context, 'فشل في حفظ التغييرات.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من الحساب؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthCubit>().signOut();
    }
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

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'مدير النظام';
      case 'hr':
        return 'الموارد البشرية';
      case 'it':
        return 'تقنية المعلومات';
      default:
        return 'موظف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loader only while actively loading
        if (state is AuthLoading) {
          return const Scaffold(body: LoadingWidget());
        }
        // If not authenticated, return empty – router will redirect immediately
        if (state is! AuthAuthenticated) {
          return const Scaffold(body: SizedBox.shrink());
        }
        final user = state.user;

        if (!_editing) {
          _nameCtrl.text = user.fullName;
          _deptCtrl.text = user.department ?? '';
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'ملفي الشخصي',
            showBack: true,
            actions: [
              if (!_editing)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => setState(() => _editing = true),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _editing = false),
                  child: const Text('إلغاء'),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // ── Avatar + Badge ──
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor:
                              _roleColor(user.role).withOpacity(0.12),
                          backgroundImage: user.avatarUrl != null
                              ? CachedNetworkImageProvider(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(user.initials,
                                  style: AppTypography.headlineMedium
                                      .copyWith(color: _roleColor(user.role)))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: isDark
                                      ? AppColors.backgroundDark
                                      : AppColors.backgroundLight,
                                  width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(user.fullName, style: AppTypography.headlineSmall),
                    const SizedBox(height: 4),
                    Text(user.email,
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
                        color: _roleColor(user.role).withOpacity(0.1),
                        borderRadius: AppRadius.fullBorderRadius,
                      ),
                      child: Text(
                        _roleLabel(user.role),
                        style: AppTypography.labelMedium.copyWith(
                          color: _roleColor(user.role),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Editable Fields ──
              if (_editing) ...[
                _FieldCard(
                  label: 'الاسم الكامل',
                  controller: _nameCtrl,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldCard(
                  label: 'القسم',
                  controller: _deptCtrl,
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_saving)
                  const Center(child: CircularProgressIndicator())
                else
                  AppButton(
                    onPressed: _saveProfile,
                    label: 'حفظ التغييرات',
                  ),
              ] else ...[
                _InfoTile(
                  label: 'الاسم',
                  value: user.fullName,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoTile(
                  label: 'البريد الإلكتروني',
                  value: user.email,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoTile(
                  label: 'القسم',
                  value: user.department ?? 'غير محدد',
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoTile(
                  label: 'الدور الوظيفي',
                  value: _roleLabel(user.role),
                  icon: Icons.badge_outlined,
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // ── Theme Toggle ──
              Builder(
                builder: (ctx) {
                  final themeCubit = ctx.watch<ThemeCubit>();
                  final isDarkMode = themeCubit.state == ThemeMode.dark;
                  final tileDark = Theme.of(ctx).brightness == Brightness.dark;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tileDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: AppRadius.lgBorderRadius,
                      boxShadow:
                          tileDark ? AppShadows.softDark : AppShadows.soft,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.warning.withOpacity(0.12),
                            borderRadius: AppRadius.mdBorderRadius,
                          ),
                          child: Icon(
                            isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: isDarkMode
                                ? AppColors.accent
                                : AppColors.warning,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المظهر', style: AppTypography.titleSmall),
                              Text(
                                isDarkMode ? 'الوضع الليلي' : 'الوضع النهاري',
                                style: AppTypography.bodySmall.copyWith(
                                  color: tileDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariantLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isDarkMode,
                          activeColor: AppColors.accent,
                          onChanged: (_) =>
                              ctx.read<ThemeCubit>().toggleTheme(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Sign Out ──
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorderRadius),
                ),
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('تسجيل الخروج'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  const _FieldCard(
      {required this.label, required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoTile(
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.smBorderRadius,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
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
