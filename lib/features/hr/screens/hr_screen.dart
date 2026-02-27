import 'package:employee_portal/features/auth/models/user_model.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/features/hr/cubit/hr_cubit.dart';
import 'package:employee_portal/features/hr/cubit/hr_state.dart';
import 'package:employee_portal/features/hr/models/hr_content_model.dart';
import 'package:employee_portal/features/hr/services/hr_service.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';
import 'package:employee_portal/shared/widgets/date_filter_bar.dart';

class HrScreen extends StatelessWidget {
  const HrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HRCubit(hrService: HRService())..loadAll(),
      child: const _HRView(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MAIN VIEW
// ═══════════════════════════════════════════════════════════════════
class _HRView extends StatefulWidget {
  final UserModel? currentUser;
  const _HRView({this.currentUser});

  @override
  State<_HRView> createState() => _HRViewState();
}

class _HRViewState extends State<_HRView> {
  DateTime? _filterDate;

  bool get _canSendAnnouncements =>
      widget.currentUser != null &&
      (widget.currentUser!.isHR || widget.currentUser!.isAdmin);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocConsumer<HRCubit, HRState>(
        listener: (context, state) {
          if (state is HRError) {
            ErrorHandler.showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'الموارد البشرية',
              bottom: TabBar(
                labelColor: AppColors.hrColor,
                unselectedLabelColor: AppColors.onSurfaceVariantLight,
                indicatorColor: AppColors.hrColor,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                      icon: Icon(Icons.policy_outlined, size: 18),
                      text: 'السياسات'),
                  Tab(
                      icon: Icon(Icons.school_outlined, size: 18),
                      text: 'التدريب'),
                  Tab(
                      icon: Icon(Icons.work_outline_rounded, size: 18),
                      text: 'الوظائف'),
                ],
              ),
            ),
            // ── FAB for HR/Admin: Send Announcement ─────────────────
            floatingActionButton: _canSendAnnouncements
                ? _AnnouncementFab(
                    onTap: () => _showAnnouncementDialog(context),
                  )
                : null,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HRState state) {
    if (state is HRLoading || state is HRInitial) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      );
    }

    if (state is HRError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<HRCubit>().loadAll(),
      );
    }

    if (state is HRLoaded) {
      return Column(
        children: [
          DateFilterBar(
            selectedDate: _filterDate,
            accentColor: AppColors.hrColor,
            onDateChanged: (d) => setState(() => _filterDate = d),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _HRList(
                  items: _filter(state.policies),
                  emptyTitle: 'لا توجد سياسات حاليًا',
                  emptyIcon: Icons.policy_outlined,
                  accentColor: AppColors.hrColor,
                  onRefresh: () => context.read<HRCubit>().loadAll(),
                ),
                _HRList(
                  items: _filter(state.trainings),
                  emptyTitle: 'لا توجد دورات تدريبية حاليًا',
                  emptyIcon: Icons.school_outlined,
                  accentColor: AppColors.primary,
                  onRefresh: () => context.read<HRCubit>().loadAll(),
                ),
                _HRList(
                  items: _filter(state.jobs),
                  emptyTitle: 'لا توجد وظائف شاغرة حاليًا',
                  emptyIcon: Icons.work_outline_rounded,
                  accentColor: AppColors.secondary,
                  onRefresh: () => context.read<HRCubit>().loadAll(),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  List<HRContentModel> _filter(List<HRContentModel> items) {
    if (_filterDate == null) return items;
    return items
        .where((e) => matchesDateFilter(e.createdAt, _filterDate))
        .toList();
  }

  bool matchesDateFilter(DateTime? itemDate, DateTime? filterDate) {
    if (itemDate == null || filterDate == null) return false;
    return itemDate.year == filterDate.year &&
        itemDate.month == filterDate.month &&
        itemDate.day == filterDate.day;
  }

  void _showAnnouncementDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnnouncementSheet(hrCubit: context.read<HRCubit>()),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANNOUNCEMENT FAB
// ═══════════════════════════════════════════════════════════════════
class _AnnouncementFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AnnouncementFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.hrColor, AppColors.hrColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.hrColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'إرسال إعلان',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ANNOUNCEMENT BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _AnnouncementSheet extends StatefulWidget {
  final HRCubit hrCubit;
  const _AnnouncementSheet({required this.hrCubit});

  @override
  State<_AnnouncementSheet> createState() => _AnnouncementSheetState();
}

class _AnnouncementSheetState extends State<_AnnouncementSheet> {
  final _service = HRService();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _isWarning = false;
  bool _sending = false;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  String? _selectedUserName;

  String get _category => _isWarning ? 'policy' : 'policy';

  @override
  void initState() {
    super.initState();
    _service.fetchUsers().then((u) {
      if (mounted) setState(() => _users = u);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    setState(() => _sending = true);
    try {
      final fullTitle = _isWarning && _selectedUserName != null
          ? '⚠️ تحذير لـ $_selectedUserName: $title'
          : '📢 $title';
      await _service.sendAnnouncement(
        title: fullTitle,
        description: body,
      );
      await widget.hrCubit.loadAll();
      if (mounted) {
        Navigator.pop(context);
        ErrorHandler.showSuccessSnackbar(
            context, 'تم إرسال الإعلان بنجاح وسيظهر للجميع الآن 🎉');
      }
    } catch (_) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, 'فشل إرسال الإعلان.');
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.hrColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: AppColors.hrColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إرسال إعلان للموظفين',
                        style: AppTypography.titleSmall),
                    Text('سيظهر كإشعار فوري لكل المستخدمين',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                        )),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Toggle: General / Warning ────────────────────────────
          Row(
            children: [
              _TypeChip(
                label: '📢 إعلان عام',
                selected: !_isWarning,
                color: AppColors.hrColor,
                onTap: () => setState(() {
                  _isWarning = false;
                  _selectedUserId = null;
                  _selectedUserName = null;
                }),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: '⚠️ تحذير موظف',
                selected: _isWarning,
                color: AppColors.error,
                onTap: () => setState(() => _isWarning = true),
              ),
            ],
          ),

          // ── Employee Selector (warning mode) ─────────────────────
          if (_isWarning) ...[
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              hint: const Text('اختر الموظف'),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                border:
                    OutlineInputBorder(borderRadius: AppRadius.lgBorderRadius),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: _users.map((u) {
                return DropdownMenuItem<String>(
                  value: u['id'] as String,
                  child:
                      Text(u['full_name'] as String? ?? u['email'] as String),
                );
              }).toList(),
              onChanged: (id) {
                final found =
                    _users.firstWhere((u) => u['id'] == id, orElse: () => {});
                setState(() {
                  _selectedUserId = id;
                  _selectedUserName = found['full_name'] as String? ?? 'الموظف';
                });
              },
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Title ─────────────────────────────────────────────────
          TextField(
            controller: _titleCtrl,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'عنوان الإعلان',
              border:
                  OutlineInputBorder(borderRadius: AppRadius.lgBorderRadius),
              prefixIcon: const Icon(Icons.title_rounded),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Body ──────────────────────────────────────────────────
          TextField(
            controller: _bodyCtrl,
            style: AppTypography.bodyMedium,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'نص الإعلان...',
              border:
                  OutlineInputBorder(borderRadius: AppRadius.lgBorderRadius),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Send Button ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: _sending
                ? const Center(child: CircularProgressIndicator())
                : AppButton.primary(
                    label: 'إرسال الآن 📤',
                    icon: Icons.send_rounded,
                    onPressed: _send,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? color : Colors.grey.withOpacity(0.3),
          ),
          borderRadius: AppRadius.fullBorderRadius,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? color : Colors.grey,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HR LIST TAB
// ═══════════════════════════════════════════════════════════════════
class _HRList extends StatelessWidget {
  final List<HRContentModel> items;
  final String emptyTitle;
  final IconData emptyIcon;
  final Color accentColor;
  final VoidCallback onRefresh;

  const _HRList({
    required this.items,
    required this.emptyTitle,
    required this.emptyIcon,
    required this.accentColor,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        icon: emptyIcon,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: accentColor,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.massive,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _HRCard(
          item: items[index],
          index: index,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HR CARD
// ═══════════════════════════════════════════════════════════════════
class _HRCard extends StatelessWidget {
  final HRContentModel item;
  final int index;
  final Color accentColor;

  const _HRCard({
    required this.item,
    required this.index,
    required this.accentColor,
  });

  Future<void> _openFile(BuildContext context) async {
    if (item.fileUrl == null) return;
    final uri = Uri.tryParse(item.fileUrl!);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ErrorHandler.showErrorSnackbar(context, 'تعذّر فتح الملف.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StaggeredListItem(
      index: index,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.lgBorderRadius,
          boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
          border: Border(
            right: BorderSide(color: accentColor, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.mdBorderRadius,
                    ),
                    child: Icon(
                      _categoryIcon(item.category),
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Title + category label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.10),
                            borderRadius: AppRadius.fullBorderRadius,
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: accentColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ─── Description ────────────────────────────────────
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // ─── File Link ───────────────────────────────────────
              if (item.fileUrl != null) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  borderRadius: AppRadius.mdBorderRadius,
                  onTap: () => _openFile(context),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attachment_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'فتح الملف المرفق',
                          style: AppTypography.labelMedium.copyWith(
                            color: accentColor,
                            decoration: TextDecoration.underline,
                            decorationColor: accentColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(HRCategory category) {
    switch (category) {
      case HRCategory.policy:
        return Icons.policy_outlined;
      case HRCategory.training:
        return Icons.school_outlined;
      case HRCategory.job:
        return Icons.work_outline_rounded;
    }
  }
}
