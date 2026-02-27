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
import 'package:employee_portal/features/it/models/it_content_model.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/app_text_field.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class ManageItScreen extends StatefulWidget {
  const ManageItScreen({super.key});

  @override
  State<ManageItScreen> createState() => _ManageItScreenState();
}

class _ManageItScreenState extends State<ManageItScreen>
    with SingleTickerProviderStateMixin {
  final _client = Supabase.instance.client;
  List<ITContentModel> _items = [];
  bool _loading = true;
  late final TabController _tabCtrl = TabController(length: 4, vsync: this);

  ITCategory get _currentCategory {
    switch (_tabCtrl.index) {
      case 1:
        return ITCategory.tip;
      case 2:
        return ITCategory.policy;
      case 3:
        return ITCategory.guide;
      default:
        return ITCategory.alert;
    }
  }

  List<ITContentModel> get _filtered =>
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
          .from(AppConstants.itContentTable)
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _items = (data as List)
            .map((e) => ITContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) ErrorHandler.showErrorSnackbar(context, 'فشل تحميل البيانات.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await _confirm('هل تريد الحذف؟');
    if (!ok) return;
    try {
      await _client.from(AppConstants.itContentTable).delete().eq('id', id);
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
                    child:
                        Text('حذف', style: TextStyle(color: AppColors.error))),
              ],
            ),
          ) ??
      false;

  void _showForm({ITContentModel? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ITFormSheet(
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
    final items = _filtered;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة IT',
        showBack: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.itColor,
          unselectedLabelColor: AppColors.onSurfaceVariantLight,
          indicatorColor: AppColors.itColor,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'تنبيهات'),
            Tab(text: 'نصائح'),
            Tab(text: 'سياسات'),
            Tab(text: 'أدلة'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.itColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('إضافة',
            style: AppTypography.labelMedium.copyWith(color: Colors.white)),
      ),
      body: _loading
          ? const LoadingWidget()
          : items.isEmpty
              ? const EmptyStateWidget(
                  title: 'لا توجد عناصر.',
                  icon: Icons.computer_outlined)
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  color: AppColors.itColor,
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
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            borderRadius: AppRadius.lgBorderRadius,
                            boxShadow: isDark
                                ? AppShadows.softDark
                                : AppShadows.soft,
                            border: item.isUrgent
                                ? Border.all(
                                    color: AppColors.error.withOpacity(0.4),
                                    width: 1.5)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (item.isUrgent
                                          ? AppColors.error
                                          : AppColors.itColor)
                                      .withOpacity(0.12),
                                  borderRadius: AppRadius.mdBorderRadius,
                                ),
                                child: Icon(
                                  item.isUrgent
                                      ? Icons.warning_amber_rounded
                                      : Icons.computer_outlined,
                                  color: item.isUrgent
                                      ? AppColors.error
                                      : AppColors.itColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(item.title,
                                              style: AppTypography.titleSmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        if (item.isUrgent)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.errorLight,
                                              borderRadius:
                                                  AppRadius.fullBorderRadius,
                                            ),
                                            child: Text('عاجل',
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                        color: AppColors.error,
                                                        fontSize: 9)),
                                          ),
                                      ],
                                    ),
                                    if (item.description != null)
                                      Text(item.description!,
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                            color: isDark
                                                ? AppColors
                                                    .onSurfaceVariantDark
                                                : AppColors
                                                    .onSurfaceVariantLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
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
// IT FORM SHEET
// ═══════════════════════════════════════════════════════════════════
class _ITFormSheet extends StatefulWidget {
  final ITContentModel? item;
  final ITCategory defaultCategory;
  final VoidCallback onSaved;

  const _ITFormSheet({
    this.item,
    required this.defaultCategory,
    required this.onSaved,
  });

  @override
  State<_ITFormSheet> createState() => _ITFormSheetState();
}

class _ITFormSheetState extends State<_ITFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.item?.title);
  late final _descCtrl =
      TextEditingController(text: widget.item?.description);
  late final _urlCtrl = TextEditingController(text: widget.item?.fileUrl);
  late ITCategory _category =
      widget.item?.category ?? widget.defaultCategory;
  late bool _isUrgent = widget.item?.isUrgent ?? false;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  String _catKey(ITCategory c) {
    switch (c) {
      case ITCategory.alert:
        return 'alert';
      case ITCategory.tip:
        return 'tip';
      case ITCategory.policy:
        return 'policy';
      case ITCategory.guide:
        return 'guide';
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
        'file_url':
            _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
        'category': _catKey(_category),
        'is_urgent': _isUrgent,
      };

      if (widget.item != null) {
        await client
            .from(AppConstants.itContentTable)
            .update(payload)
            .eq('id', widget.item!.id);
      } else {
        await client.from(AppConstants.itContentTable).insert(payload);
      }
      widget.onSaved();
    } catch (_) {
      if (mounted) ErrorHandler.showErrorSnackbar(context, 'فشل الحفظ.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                widget.item == null ? 'إضافة عنصر IT' : 'تعديل العنصر',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<ITCategory>(
                  segments: const [
                    ButtonSegment(
                        value: ITCategory.alert, label: Text('تنبيه')),
                    ButtonSegment(
                        value: ITCategory.tip, label: Text('نصيحة')),
                    ButtonSegment(
                        value: ITCategory.policy, label: Text('سياسة')),
                    ButtonSegment(
                        value: ITCategory.guide, label: Text('دليل')),
                  ],
                  selected: {_category},
                  onSelectionChanged: (s) =>
                      setState(() => _category = s.first),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.itColor;
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
              ),
              const SizedBox(height: AppSpacing.md),

              // Urgent toggle
              SwitchListTile(
                value: _isUrgent,
                onChanged: (v) => setState(() => _isUrgent = v),
                title: const Text('تنبيه عاجل'),
                subtitle: const Text('سيظهر بحدود حمراء'),
                activeColor: AppColors.error,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
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
                hint: 'تفاصيل العنصر',
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
                label: widget.item == null ? 'إضافة' : 'حفظ التعديلات',
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
