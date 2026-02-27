import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/features/hr/models/hr_content_model.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/app_text_field.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class ManageHrScreen extends StatefulWidget {
  const ManageHrScreen({super.key});

  @override
  State<ManageHrScreen> createState() => _ManageHrScreenState();
}

class _ManageHrScreenState extends State<ManageHrScreen>
    with SingleTickerProviderStateMixin {
  final _client = Supabase.instance.client;
  List<HRContentModel> _items = [];
  bool _loading = true;
  late final TabController _tabCtrl = TabController(length: 3, vsync: this);

  HRCategory get _currentCategory {
    switch (_tabCtrl.index) {
      case 1:
        return HRCategory.training;
      case 2:
        return HRCategory.job;
      default:
        return HRCategory.policy;
    }
  }

  List<HRContentModel> get _filteredItems =>
      _items.where((e) => e.category == _currentCategory).toList();

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final data = await _client
          .from(AppConstants.hrContentTable)
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _items = (data as List)
            .map((e) => HRContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, 'فشل تحميل بيانات HR.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await _confirm('هل تريد حذف هذا العنصر؟');
    if (!ok) return;
    try {
      await _client.from(AppConstants.hrContentTable).delete().eq('id', id);
      ErrorHandler.showSuccessSnackbar(context, 'تم الحذف.');
      _fetchAll();
    } catch (_) {
      ErrorHandler.showErrorSnackbar(context, 'فشل الحذف.');
    }
  }

  Future<bool> _confirm(String msg) async =>
      await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('تأكيد'),
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('إلغاء')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('حذف',
                        style: TextStyle(color: AppColors.error))),
              ],
            ),
          ) ??
      false;

  void _showForm({HRContentModel? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HRFormSheet(
        item: item,
        defaultCategory: _currentCategory,
        onSaved: () {
          Navigator.pop(context);
          _fetchAll();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة الموارد البشرية',
        showBack: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.hrColor,
          unselectedLabelColor: AppColors.onSurfaceVariantLight,
          indicatorColor: AppColors.hrColor,
          tabs: const [
            Tab(text: 'السياسات'),
            Tab(text: 'التدريب'),
            Tab(text: 'الوظائف'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.hrColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('إضافة',
            style: AppTypography.labelMedium.copyWith(color: Colors.white)),
      ),
      body: _loading
          ? const LoadingWidget()
          : items.isEmpty
              ? const EmptyStateWidget(
                  title: 'لا توجد عناصر.',
                  icon: Icons.people_outline_rounded)
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  color: AppColors.hrColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return StaggeredListItem(
                        index: i,
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
                            border: Border(
                                right: BorderSide(
                                    color: AppColors.hrColor, width: 3)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title,
                                        style: AppTypography.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    if (item.description != null)
                                      Text(item.description!,
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                  color: isDark
                                                      ? AppColors
                                                          .onSurfaceVariantDark
                                                      : AppColors
                                                          .onSurfaceVariantLight),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    if (item.fileUrl != null)
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.attachment_rounded,
                                              size: 12,
                                              color: AppColors.hrColor),
                                          const SizedBox(width: 4),
                                          Text('مرفق',
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                      color:
                                                          AppColors.hrColor)),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.edit_outlined, size: 20),
                                color: AppColors.primary,
                                onPressed: () => _showForm(item: item),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20),
                                color: AppColors.error,
                                onPressed: () => _delete(item.id),
                              ),
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

// ═══════════════════════════════════════════════════════════════════
// HR FORM SHEET
// ═══════════════════════════════════════════════════════════════════
class _HRFormSheet extends StatefulWidget {
  final HRContentModel? item;
  final HRCategory defaultCategory;
  final VoidCallback onSaved;

  const _HRFormSheet({
    this.item,
    required this.defaultCategory,
    required this.onSaved,
  });

  @override
  State<_HRFormSheet> createState() => _HRFormSheetState();
}

class _HRFormSheetState extends State<_HRFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl =
      TextEditingController(text: widget.item?.title);
  late final _descCtrl =
      TextEditingController(text: widget.item?.description);
  late final _urlCtrl =
      TextEditingController(text: widget.item?.fileUrl);
  late HRCategory _category =
      widget.item?.category ?? widget.defaultCategory;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  String _categoryKey(HRCategory c) {
    switch (c) {
      case HRCategory.policy:
        return 'policy';
      case HRCategory.training:
        return 'training';
      case HRCategory.job:
        return 'job';
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final payload = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        'file_url': _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
        'category': _categoryKey(_category),
      };

      if (widget.item != null) {
        await client
            .from(AppConstants.hrContentTable)
            .update(payload)
            .eq('id', widget.item!.id);
      } else {
        await client.from(AppConstants.hrContentTable).insert(payload);
      }
      widget.onSaved();
    } catch (_) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, 'فشل الحفظ.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg,
                AppSpacing.lg, MediaQuery.of(context).viewInsets.bottom + 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                    borderRadius: AppRadius.fullBorderRadius,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.item == null ? 'إضافة عنصر' : 'تعديل العنصر',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category selector
              SegmentedButton<HRCategory>(
                segments: const [
                  ButtonSegment(
                      value: HRCategory.policy, label: Text('سياسة')),
                  ButtonSegment(
                      value: HRCategory.training, label: Text('تدريب')),
                  ButtonSegment(value: HRCategory.job, label: Text('وظيفة')),
                ],
                selected: {_category},
                onSelectionChanged: (s) =>
                    setState(() => _category = s.first),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.hrColor;
                    }
                    return null;
                  }),
                  foregroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _titleCtrl,
                label: 'العنوان',
                hint: 'عنوان العنصر',
                validator: (v) =>
                    v == null || v.isEmpty ? 'العنوان مطلوب' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _descCtrl,
                label: 'الوصف (اختياري)',
                hint: 'وصف مختصر',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _urlCtrl,
                label: 'رابط الملف (اختياري)',
                hint: 'https://...',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton.primary(
                label: widget.item == null ? 'إضافة' : 'حفظ',
                icon: Icons.save_rounded,
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
