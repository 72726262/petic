import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/animations/app_animations.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/mood/cubit/mood_cubit.dart';
import 'package:employee_portal/features/mood/cubit/mood_state.dart';
import 'package:employee_portal/features/mood/models/mood_model.dart';
import 'package:employee_portal/features/mood/services/mood_service.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

import 'package:intl/intl.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final user =
        authState is AuthAuthenticated ? authState.user : null;

    // Admin gets a dashboard; regular employees get their personal view
    if (user != null && user.isAdmin) {
      return const _AdminMoodView();
    }

    return BlocProvider(
      create: (_) {
        final cubit = MoodCubit(moodService: MoodService());
        if (user != null) cubit.loadMoods(user.id);
        return cubit;
      },
      child: _MoodView(userId: user?.id),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADMIN: All-Employee Mood Dashboard with Day Filter
// ═══════════════════════════════════════════════════════════════════════════
class _AdminMoodView extends StatefulWidget {
  const _AdminMoodView();

  @override
  State<_AdminMoodView> createState() => _AdminMoodViewState();
}

class _AdminMoodViewState extends State<_AdminMoodView> {
  final _service = MoodService();
  DateTime _selectedDate = DateTime.now();
  List<AdminMoodEntry> _entries = [];
  List<Map<String, dynamic>> _allUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.fetchAllMoodsForDate(_selectedDate),
        _service.fetchAllUsers(),
      ]);
      if (mounted) {
        setState(() {
          _entries = results[0] as List<AdminMoodEntry>;
          _allUsers = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('dd MMMM yyyy', 'ar').format(_selectedDate);

    // Count moods
    final Map<String, int> counts = {};
    for (final e in _entries) {
      final key = e.mood.moodKey;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'مزاج الموظفين',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            tooltip: 'اختر يوماً',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.moodColor,
        child: _loading
            ? const LoadingWidget()
            : CustomScrollView(
                slivers: [
                  // ── Date Header ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppColors.moodGradient,
                            borderRadius: AppRadius.lgBorderRadius,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  dateStr,
                                  style: AppTypography.titleSmall
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: AppRadius.fullBorderRadius,
                                ),
                                child: Text(
                                  '${_entries.length}${_allUsers.isEmpty ? '' : '/${_allUsers.length}'} سجّلوا',
                                  style: AppTypography.labelMedium
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Mood Stats Chips ───────────────────────────────
                  if (_entries.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _MoodStatChip(emoji: '😁', label: 'ممتاز', count: counts['excellent'] ?? 0, color: AppColors.moodExcellent),
                            _MoodStatChip(emoji: '😊', label: 'جيد', count: counts['good'] ?? 0, color: AppColors.moodGood),
                            _MoodStatChip(emoji: '😐', label: 'محايد', count: counts['neutral'] ?? 0, color: AppColors.moodNeutral),
                            _MoodStatChip(emoji: '😔', label: 'سيئ', count: counts['bad'] ?? 0, color: AppColors.moodBad),
                            _MoodStatChip(emoji: '😞', label: 'رديء', count: counts['terrible'] ?? 0, color: AppColors.moodTerrible),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

                  // ── Employee List ──────────────────────────────────
                  _entries.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('😶', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 12),
                                Text('لا توجد بيانات لهذا اليوم',
                                    style: AppTypography.bodyMedium),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: _AdminMoodTile(
                                    entry: _entries[i], isDark: isDark),
                              ),
                              childCount: _entries.length,
                            ),
                          ),
                        ),

                  // ── Not Submitted Section ──────────────────────────
                  if (_allUsers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Builder(builder: (context) {
                        final submittedIds = _entries.map((e) => e.userId).toSet();
                        final notSubmitted = _allUsers
                            .where((u) => !submittedIds.contains(u['id'] as String))
                            .toList();

                        if (notSubmitted.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.12),
                                  borderRadius: AppRadius.lgBorderRadius,
                                  border: Border.all(
                                    color: AppColors.warning.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: AppColors.warning, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'لم يسجلوا مزاجهم اليوم — ${notSubmitted.length} موظف',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...notSubmitted.map((u) {
                                final name = u['full_name'] as String? ??
                                    u['email'] as String? ?? 'موظف';
                                final role = u['role'] as String? ?? 'user';
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.xs),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            AppColors.warning.withOpacity(0.15),
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : '?',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                  color: AppColors.warning),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(name,
                                            style: AppTypography.bodySmall),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.warning.withOpacity(0.1),
                                          borderRadius:
                                              AppRadius.fullBorderRadius,
                                        ),
                                        child: Text(
                                          role == 'admin'
                                              ? 'مدير'
                                              : role == 'hr'
                                                  ? 'موارد '
                                                  : role == 'it'
                                                      ? 'تقنية'
                                                      : 'موظف',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],

                  const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.huge)),
                ],
              ),
      ),
    );
  }
}

class _MoodStatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _MoodStatChip({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.fullBorderRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: color)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.fullBorderRadius,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMoodTile extends StatelessWidget {
  final AdminMoodEntry entry;
  final bool isDark;

  const _AdminMoodTile({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mood = entry.mood;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
      ),
      child: Row(
        children: [
          // Mood emoji bubble
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _moodColor(mood.mood).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(mood.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.employeeName, style: AppTypography.titleSmall),
                Text(
                  entry.employeeEmail,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight,
                  ),
                ),
                if (mood.note != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '"${mood.note!}"',
                    style: AppTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariantLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Mood label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _moodColor(mood.mood).withOpacity(0.12),
              borderRadius: AppRadius.fullBorderRadius,
            ),
            child: Text(
              mood.label,
              style: AppTypography.labelSmall.copyWith(
                color: _moodColor(mood.mood),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _moodColor(MoodLevel level) {
    switch (level) {
      case MoodLevel.excellent: return AppColors.moodExcellent;
      case MoodLevel.good: return AppColors.moodGood;
      case MoodLevel.neutral: return AppColors.moodNeutral;
      case MoodLevel.bad: return AppColors.moodBad;
      case MoodLevel.terrible: return AppColors.moodTerrible;
    }
  }
}


class _MoodView extends StatefulWidget {
  final String? userId;
  const _MoodView({required this.userId});

  @override
  State<_MoodView> createState() => _MoodViewState();
}

class _MoodViewState extends State<_MoodView> {
  MoodLevel? _selected;
  final _noteCtrl = TextEditingController();

  static const _moods = [
    MoodLevel.excellent,
    MoodLevel.good,
    MoodLevel.neutral,
    MoodLevel.bad,
    MoodLevel.terrible,
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MoodCubit, MoodState>(
      listener: (context, state) {
        if (state is MoodError) {
          ErrorHandler.showErrorSnackbar(context, state.message);
        }
        if (state is MoodSubmitSuccess) {
          ErrorHandler.showSuccessSnackbar(context, 'تم تسجيل مزاجك اليوم 🎉');
          setState(() {
            _selected = null;
            _noteCtrl.clear();
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'مزاجك اليوم',
            showBack: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (widget.userId != null) {
                context.read<MoodCubit>().loadMoods(widget.userId!);
              }
            },
            color: AppColors.moodColor,
            child: state is MoodLoading || state is MoodInitial
                ? const LoadingWidget()
                : state is MoodLoaded
                    ? _buildContent(context, state)
                    : state is MoodSubmitting
                        ? const LoadingWidget()
                        : state is MoodError
                            ? ErrorStateWidget(
                                message: state.message,
                                onRetry: () {
                                  if (widget.userId != null) {
                                    context
                                        .read<MoodCubit>()
                                        .loadMoods(widget.userId!);
                                  }
                                },
                              )
                            : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, MoodLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alreadySubmitted = state.todayMood != null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ─── Today's Mood Picker ──────────────────────────────────
        FadeSlideUp(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: alreadySubmitted
                  ? AppColors.moodGradient
                  : null,
              color: alreadySubmitted
                  ? null
                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
              borderRadius: AppRadius.xlBorderRadius,
              boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
            ),
            child: alreadySubmitted
                ? _AlreadySubmittedBanner(mood: state.todayMood!)
                : _MoodPicker(
                    moods: _moods,
                    selected: _selected,
                    noteCtrl: _noteCtrl,
                    onSelected: (m) => setState(() => _selected = m),
                    onSubmit: _selected == null || widget.userId == null
                        ? null
                        : () {
                            context.read<MoodCubit>().submitMood(
                                  userId: widget.userId!,
                                  mood: _selected!,
                                  note: _noteCtrl.text.trim().isEmpty
                                      ? null
                                      : _noteCtrl.text.trim(),
                                );
                          },
                  ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ─── Chart Title ──────────────────────────────────────────
        if (state.history.isNotEmpty) ...[
          Text(
            'مزاجك خلال 30 يومًا',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          // Bar Chart
          _MoodBarChart(history: state.history),

          const SizedBox(height: AppSpacing.xl),

          // History list
          Text(
            'السجل التفصيلي',
            style: AppTypography.titleSmall.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ...state.history
              .take(10)
              .toList()
              .asMap()
              .entries
              .map((e) => _HistoryTile(mood: e.value, index: e.key)),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ALREADY SUBMITTED BANNER
// ═══════════════════════════════════════════════════════════════════
class _AlreadySubmittedBanner extends StatelessWidget {
  final MoodModel mood;
  const _AlreadySubmittedBanner({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(mood.emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'سجّلت مزاجك اليوم!',
          style: AppTypography.titleMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          mood.label,
          style: AppTypography.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (mood.note != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"${mood.note!}"',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MOOD PICKER
// ═══════════════════════════════════════════════════════════════════
class _MoodPicker extends StatelessWidget {
  final List<MoodLevel> moods;
  final MoodLevel? selected;
  final TextEditingController noteCtrl;
  final ValueChanged<MoodLevel> onSelected;
  final VoidCallback? onSubmit;

  const _MoodPicker({
    required this.moods,
    required this.selected,
    required this.noteCtrl,
    required this.onSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          'كيف حالك اليوم؟',
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Emoji row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: moods.map((m) {
            final dummy = MoodModel(
              id: '',
              userId: '',
              mood: m,
              createdAt: DateTime.now(),
            );
            final isSelected = selected == m;

            return GestureDetector(
              onTap: () => onSelected(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: isSelected ? 62 : 52,
                height: isSelected ? 62 : 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.moodColor.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: AppColors.moodColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    dummy.emoji,
                    style: TextStyle(fontSize: isSelected ? 32 : 28),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Selected label
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            MoodModel(
                    id: '', userId: '', mood: selected!, createdAt: DateTime.now())
                .label,
            style: AppTypography.titleSmall.copyWith(color: AppColors.moodColor),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Note field
        TextField(
          controller: noteCtrl,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: 'أضف ملاحظة (اختياري)',
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            border: OutlineInputBorder(
              borderRadius: AppRadius.lgBorderRadius,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
          maxLines: 2,
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton.primary(
          label: 'سجّل مزاجي',
          icon: Icons.sentiment_satisfied_alt_rounded,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MOOD BAR CHART
// ═══════════════════════════════════════════════════════════════════
class _MoodBarChart extends StatelessWidget {
  final List<MoodModel> history;
  const _MoodBarChart({required this.history});

  int _moodToScore(MoodLevel level) {
    switch (level) {
      case MoodLevel.excellent:
        return 5;
      case MoodLevel.good:
        return 4;
      case MoodLevel.neutral:
        return 3;
      case MoodLevel.bad:
        return 2;
      case MoodLevel.terrible:
        return 1;
    }
  }

  Color _moodToColor(MoodLevel level) {
    switch (level) {
      case MoodLevel.excellent:
        return AppColors.success;
      case MoodLevel.good:
        return AppColors.primary;
      case MoodLevel.neutral:
        return AppColors.warning;
      case MoodLevel.bad:
        return AppColors.secondaryOrange;
      case MoodLevel.terrible:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Take last 14 entries
    final data = history.reversed.take(14).toList().reversed.toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
      ),
      child: BarChart(
        BarChartData(
          maxY: 5.5,
          minY: 0,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: (isDark ? AppColors.dividerDark : AppColors.dividerLight)
                  .withOpacity(0.5),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 24,
                getTitlesWidget: (val, meta) {
                  const emojis = {1: '😢', 2: '😔', 3: '😐', 4: '😊', 5: '😄'};
                  final e = emojis[val.toInt()];
                  if (e == null) return const SizedBox.shrink();
                  return Text(e, style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final date = data[idx].createdAt;
                  return Text(
                    '${date.day}/${date.month}',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 9,
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariantLight,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: data.asMap().entries.map((entry) {
            final score = _moodToScore(entry.value.mood);
            final color = _moodToColor(entry.value.mood);
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: score.toDouble(),
                  color: color,
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 5,
                    color: color.withOpacity(0.08),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HISTORY TILE
// ═══════════════════════════════════════════════════════════════════
class _HistoryTile extends StatelessWidget {
  final MoodModel mood;
  final int index;

  const _HistoryTile({required this.mood, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StaggeredListItem(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
          ),
          child: Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mood.label, style: AppTypography.titleSmall),
                    if (mood.note != null)
                      Text(
                        mood.note!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Text(
                AppUtils.formatRelative(mood.createdAt),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
