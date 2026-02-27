import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/features/events/models/event_model.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/app_text_field.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final _client = Supabase.instance.client;
  List<EventModel> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _loading = true);
    try {
      final data = await _client
          .from(AppConstants.eventsTable)
          .select()
          .order('date', ascending: true);

      setState(() {
        _events = (data as List)
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, 'فشل تحميل الفعاليات.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteEvent(String id) async {
    final confirmed = await _confirm('هل تريد حذف هذه الفعالية؟');
    if (!confirmed) return;
    try {
      await _client.from(AppConstants.eventsTable).delete().eq('id', id);
      ErrorHandler.showSuccessSnackbar(context, 'تم حذف الفعالية.');
      _fetchEvents();
    } catch (_) {
      ErrorHandler.showErrorSnackbar(context, 'فشل حذف الفعالية.');
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
                    child: Text('تأكيد',
                        style: TextStyle(color: AppColors.error))),
              ],
            ),
          ) ??
      false;

  void _showAddEditSheet({EventModel? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _EventFormSheet(
        event: event,
        onSaved: () {
          // Pop the sheet using the sheet's own navigator context
          Navigator.of(sheetCtx).pop();
          _fetchEvents();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة الفعاليات',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(),
        backgroundColor: AppColors.eventsColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('فعالية جديدة',
            style: AppTypography.labelMedium.copyWith(color: Colors.white)),
      ),
      body: _loading
          ? const LoadingWidget()
          : _events.isEmpty
              ? const EmptyStateWidget(
                  title: 'لا توجد فعاليات.',
                  icon: Icons.event_outlined)
              : RefreshIndicator(
                  onRefresh: _fetchEvents,
                  color: AppColors.eventsColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
                    itemCount: _events.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final ev = _events[i];
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
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.eventsColor,
                                      AppColors.eventsColor.withOpacity(0.6)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: AppRadius.mdBorderRadius,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ev.date.day.toString(),
                                      style: AppTypography.titleMedium
                                          .copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      AppUtils.getMonthInArabic(ev.date.month)
                                          .substring(0, 3),
                                      style: AppTypography.labelSmall.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(ev.title,
                                        style: AppTypography.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    if (ev.location != null)
                                      Text(ev.location!,
                                          style:
                                              AppTypography.bodySmall.copyWith(
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
                                onPressed: () => _showAddEditSheet(event: ev),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20),
                                color: AppColors.error,
                                onPressed: () => _deleteEvent(ev.id),
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
// EVENT FORM SHEET (Add / Edit)
// ═══════════════════════════════════════════════════════════════════
class _EventFormSheet extends StatefulWidget {
  final EventModel? event;
  final VoidCallback onSaved;

  const _EventFormSheet({this.event, required this.onSaved});

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(
      text: widget.event?.title);
  late final _descCtrl = TextEditingController(
      text: widget.event?.description);
  late final _locationCtrl = TextEditingController(
      text: widget.event?.location);
  // Dynamic poll options
  late final List<TextEditingController> _pollCtrls;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.event?.date ?? DateTime.now();
    // Pre-fill poll options or start with 2 empty
    final existing = widget.event?.pollOptions ?? [];
    if (existing.isNotEmpty) {
      _pollCtrls = existing
          .map((o) => TextEditingController(text: o))
          .toList();
    } else {
      _pollCtrls = [TextEditingController(), TextEditingController()];
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    for (final c in _pollCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final client = Supabase.instance.client;
      final pollOptions = _pollCtrls
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final payload = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        'date': _selectedDate.toIso8601String(),
        'poll_options': pollOptions,
      };

      if (widget.event != null) {
        await client
            .from(AppConstants.eventsTable)
            .update(payload)
            .eq('id', widget.event!.id);
      } else {
        await client.from(AppConstants.eventsTable).insert(payload);
      }

      widget.onSaved();
    } catch (_) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, 'فشل حفظ الفعالية.');
      }
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
      minChildSize: 0.5,
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
              // Handle bar
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
                widget.event == null ? 'فعالية جديدة' : 'تعديل الفعالية',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),

              AppTextField(
                controller: _titleCtrl,
                label: 'العنوان',
                hint: 'أدخل عنوان الفعالية',
                validator: (v) => v == null || v.isEmpty
                    ? 'العنوان مطلوب'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _descCtrl,
                label: 'الوصف (اختياري)',
                hint: 'وصف الفعالية',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _locationCtrl,
                label: 'الموقع (اختياري)',
                hint: 'قاعة الاجتماعات، الطابق ...',
              ),
              const SizedBox(height: AppSpacing.md),

              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceVariantLight,
                    borderRadius: AppRadius.lgBorderRadius,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.eventsColor),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        AppUtils.formatDate(_selectedDate),
                        style: AppTypography.bodyMedium,
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_left_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Poll Options (Dynamic) ──────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceVariantLight,
                  borderRadius: AppRadius.lgBorderRadius,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.how_to_vote_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('خيارات التصويت (اختياري)',
                            style: AppTypography.titleSmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Dynamic options
                    ...List.generate(_pollCtrls.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _pollCtrls[i],
                                style: AppTypography.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: 'الخيار ${i + 1}',
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceLight,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.mdBorderRadius,
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            if (_pollCtrls.length > 2)
                              IconButton(
                                icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.error,
                                    size: 20),
                                onPressed: () =>
                                    setState(() {
                                      _pollCtrls[i].dispose();
                                      _pollCtrls.removeAt(i);
                                    }),
                              ),
                          ],
                        ),
                      );
                    }),
                    // Add option button
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _pollCtrls.add(TextEditingController());
                      }),
                      icon: const Icon(Icons.add_circle_outline,
                          size: 18, color: AppColors.primary),
                      label: Text('إضافة خيار',
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              AppButton.primary(
                label: widget.event == null ? 'إضافة الفعالية' : 'حفظ التعديلات',
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
