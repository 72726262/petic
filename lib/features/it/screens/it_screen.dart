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
import 'package:employee_portal/features/it/cubit/it_cubit.dart';
import 'package:employee_portal/features/it/cubit/it_state.dart';
import 'package:employee_portal/features/it/models/it_content_model.dart';
import 'package:employee_portal/features/it/services/it_service.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';
import 'package:employee_portal/shared/widgets/date_filter_bar.dart';

class ItScreen extends StatelessWidget {
  const ItScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ITCubit(itService: ITService())..loadAll(),
      child: const _ITView(),
    );
  }
}

class _ITView extends StatefulWidget {
  const _ITView();

  @override
  State<_ITView> createState() => _ITViewState();
}

class _ITViewState extends State<_ITView> {
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: BlocConsumer<ITCubit, ITState>(
        listener: (context, state) {
          if (state is ITError) {
            ErrorHandler.showErrorSnackbar(context, state.message);
          }
        },
        builder: (context, state) {
          ITLoaded? loaded;
          if (state is ITLoaded) loaded = state;
          return Scaffold(
            appBar: CustomAppBar(
              title: 'تقنية المعلومات',
              showBack: true,
              bottom: TabBar(
                labelColor: AppColors.itColor,
                unselectedLabelColor: AppColors.onSurfaceVariantLight,
                indicatorColor: AppColors.itColor,
                indicatorWeight: 3,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTypography.labelMedium,
                tabs: const [
                  Tab(text: 'تنبيهات'),
                  Tab(text: 'نصائح'),
                  Tab(text: 'السياسات'),
                  Tab(text: 'الأدلة'),
                ],
              ),
            ),
            body: state is ITLoading || state is ITInitial
                ? const LoadingWidget()
                : state is ITError
                    ? ErrorStateWidget(
                        message: state.message,
                        onRetry: () => context.read<ITCubit>().loadAll(),
                      )
                    : loaded != null
                        ? Column(
                            children: [
                              // Date filter bar
                              DateFilterBar(
                                selectedDate: _filterDate,
                                accentColor: AppColors.itColor,
                                onDateChanged: (d) =>
                                    setState(() => _filterDate = d),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _ITContentList(
                                      items: _filter(loaded.alerts),
                                      emptyMessage: 'لا توجد تنبيهات.',
                                      icon: Icons.warning_amber_rounded,
                                      color: AppColors.error,
                                    ),
                                    _ITContentList(
                                      items: _filter(loaded.tips),
                                      emptyMessage: 'لا توجد نصائح.',
                                      icon: Icons.lightbulb_outline_rounded,
                                      color: AppColors.warning,
                                    ),
                                    _ITContentList(
                                      items: _filter(loaded.policies),
                                      emptyMessage: 'لا توجد سياسات.',
                                      icon: Icons.policy_outlined,
                                      color: AppColors.itColor,
                                    ),
                                    _ITContentList(
                                      items: _filter(loaded.guides),
                                      emptyMessage: 'لا توجد أدلة.',
                                      icon: Icons.menu_book_outlined,
                                      color: AppColors.accent,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  List<ITContentModel> _filter(List<ITContentModel> items) {
    if (_filterDate == null) return items;
    return items
        .where((e) => matchesDateFilter(e.createdAt, _filterDate))
        .toList();
  }
}

// ═══════════════════════════════════════════════════════════════════
// IT CONTENT LIST
// ═══════════════════════════════════════════════════════════════════
class _ITContentList extends StatelessWidget {
  final List<ITContentModel> items;
  final String emptyMessage;
  final IconData icon;
  final Color color;

  const _ITContentList({
    required this.items,
    required this.emptyMessage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateWidget(title: emptyMessage, icon: icon);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ITCubit>().loadAll(),
      color: AppColors.itColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _ITCard(
          item: items[index],
          index: index,
          accentColor: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// IT CARD
// ═══════════════════════════════════════════════════════════════════
class _ITCard extends StatelessWidget {
  final ITContentModel item;
  final int index;
  final Color accentColor;

  const _ITCard({
    required this.item,
    required this.index,
    required this.accentColor,
  });

  Future<void> _openFile() async {
    if (item.fileUrl == null) return;
    final uri = Uri.parse(item.fileUrl!);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StaggeredListItem(
      index: index,
      child: PressEffect(
        onTap: item.fileUrl != null ? _openFile : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
            // Urgent items get a warning background tint
            border: item.isUrgent
                ? Border.all(
                    color: AppColors.error.withOpacity(0.4), width: 1.5)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: AppRadius.mdBorderRadius,
                ),
                child: Icon(
                  item.category == ITCategory.alert
                      ? Icons.warning_amber_rounded
                      : item.category == ITCategory.tip
                          ? Icons.lightbulb_outline_rounded
                          : item.category == ITCategory.guide
                              ? Icons.menu_book_outlined
                              : Icons.policy_outlined,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.titleSmall.copyWith(
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurfaceLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isUrgent)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: AppRadius.fullBorderRadius,
                            ),
                            child: Text(
                              'عاجل',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              if (item.fileUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(Icons.download_rounded,
                      color: accentColor, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
