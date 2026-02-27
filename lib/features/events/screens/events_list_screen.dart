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
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/features/events/cubit/event_cubit.dart';
import 'package:employee_portal/features/events/cubit/event_state.dart';
import 'package:employee_portal/features/events/models/event_model.dart';
import 'package:employee_portal/features/events/services/event_service.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

import 'package:employee_portal/shared/widgets/date_filter_bar.dart';

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventCubit(eventService: EventService())
        ..loadEvents()
        ..subscribeToRealtime(),
      child: const _EventsListView(),
    );
  }
}

class _EventsListView extends StatefulWidget {
  const _EventsListView();

  @override
  State<_EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends State<_EventsListView> {
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventCubit, EventState>(
      listener: (context, state) {
        if (state is EventError) {
          ErrorHandler.showErrorSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'الفعاليات', showBack: true),
          body: Column(
            children: [
              // ── Date Filter Bar ──────────────────────────────────
              DateFilterBar(
                selectedDate: _filterDate,
                accentColor: AppColors.eventsColor,
                onDateChanged: (d) => setState(() => _filterDate = d),
              ),
              // ── Content ──────────────────────────────────────────
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, EventState state) {
    if (state is EventLoading || state is EventInitial) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      );
    }

    if (state is EventError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<EventCubit>().loadEvents(),
      );
    }

    if (state is EventsLoaded) {
      // Apply date filter on event.date (the event's scheduled date)
      final filtered = _filterDate == null
          ? state.events
          : state.events
              .where((e) => matchesDateFilter(e.date, _filterDate))
              .toList();

      if (filtered.isEmpty) {
        return EmptyStateWidget(
          title: _filterDate == null
              ? 'لا توجد فعاليات قادمة'
              : 'لا توجد فعاليات في هذا اليوم',
          subtitle: _filterDate == null
              ? 'تابعنا لمعرفة الفعاليات الجديدة.'
              : 'جرّب تاريخاً آخر أو اعرض كل الفعاليات.',
          icon: Icons.event_busy_outlined,
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<EventCubit>().loadEvents(),
        color: AppColors.eventsColor,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => _EventCard(
            event: filtered[index],
            index: index,
            onTap: () => context.push(
              '${RouteNames.eventsList}/${filtered[index].id}',
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENT CARD
// ═══════════════════════════════════════════════════════════════════
class _EventCard extends StatelessWidget {
  final EventModel event;
  final int index;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = event.date;

    return StaggeredListItem(
      index: index,
      child: PressEffect(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.lgBorderRadius,
            boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Box
              Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.eventsColor == AppColors.eventsColor
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.eventsColor, Color(0xFFF472B6)],
                        )
                      : null,
                  color: AppColors.eventsColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      AppUtils.getMonthInArabic(date.month),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      date.year.toString(),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceDark
                              : AppColors.onSurfaceLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (event.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariantLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        children: [
                          if (event.location != null) ...[
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.eventsColor,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                event.location!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.eventsColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],

                          if (event.pollOptions != null &&
                              event.pollOptions!.isNotEmpty) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: AppRadius.fullBorderRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.how_to_vote_outlined,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'تصويت',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
