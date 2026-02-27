import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/theme/app_shadows.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/events/cubit/event_cubit.dart';
import 'package:employee_portal/features/events/cubit/event_state.dart';
import 'package:employee_portal/features/events/models/event_model.dart';
import 'package:employee_portal/features/events/services/event_service.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventCubit(eventService: EventService())
        ..loadEventDetail(eventId),
      child: _EventDetailView(eventId: eventId),
    );
  }
}

class _EventDetailView extends StatefulWidget {
  final String eventId;
  const _EventDetailView({required this.eventId});

  @override
  State<_EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<_EventDetailView> {
  final _commentCtrl = TextEditingController();
  String? _selectedOption;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventCubit, EventState>(
      listener: (context, state) {
        if (state is EventError) {
          ErrorHandler.showErrorSnackbar(context, state.message);
        }
        if (state is EventActionSuccess) {
          ErrorHandler.showSuccessSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is EventDetailLoading || state is EventInitial) {
          return Scaffold(
            appBar: AppBar(leading: BackButton()),
            body: const LoadingWidget(),
          );
        }

        if (state is EventError) {
          return Scaffold(
            appBar: AppBar(leading: BackButton()),
            body: ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<EventCubit>().loadEventDetail(widget.eventId),
            ),
          );
        }

        if (state is EventDetailLoaded) {
          final event = state.event;
          final votes = state.votes;
          final comments = state.comments;
          final authState = context.read<AuthCubit>().state;
          final userId = authState is AuthAuthenticated
              ? authState.user.id
              : null;

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // ─── App Bar ─────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.eventsColor,
                            Color(0xFFF472B6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  leading: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  title: Text(
                    'تفاصيل الفعالية',
                    style: AppTypography.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                  centerTitle: true,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Event Header ─────────────────────────
                        _EventHeader(event: event),
                        const SizedBox(height: AppSpacing.xl),

                        // ─── Description ──────────────────────────
                        if (event.description != null) ...[
                          Text(
                            event.description!,
                            style: AppTypography.bodyLarge.copyWith(
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // ─── Poll Section ─────────────────────────
                        if (event.pollOptions.isNotEmpty)
                          _PollSection(
                            event: event,
                            votes: votes,
                            userId: userId,
                            selectedOption: _selectedOption,
                            onOptionSelected: (opt) =>
                                setState(() => _selectedOption = opt),
                            onVote: userId == null
                                ? null
                                : () {
                                    if (_selectedOption == null) return;
                                    context.read<EventCubit>().submitVote(
                                          eventId: event.id,
                                          userId: userId,
                                          option: _selectedOption!,
                                        );
                                  },
                          ),

                        const SizedBox(height: AppSpacing.xxl),

                        // ─── Comments Section ─────────────────────
                        _CommentsSection(
                          comments: comments,
                          userId: userId,
                          commentCtrl: _commentCtrl,
                          onSubmit: userId == null
                              ? null
                              : () {
                                  final text = _commentCtrl.text.trim();
                                  if (text.isEmpty) return;
                                  context.read<EventCubit>().addComment(
                                        eventId: event.id,
                                        userId: userId,
                                        comment: text,
                                      );
                                  _commentCtrl.clear();
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENT HEADER
// ═══════════════════════════════════════════════════════════════════
class _EventHeader extends StatelessWidget {
  final EventModel event;
  const _EventHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: AppTypography.headlineSmall.copyWith(height: 1.3),
          ),
          const SizedBox(height: AppSpacing.md),

          _InfoRow(
            icon: Icons.calendar_today_outlined,
            color: AppColors.eventsColor,
            text: AppUtils.formatDate(event.date),
          ),
          if (event.location != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.location_on_outlined,
              color: AppColors.primary,
              text: event.location!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: AppTypography.bodyMedium.copyWith(color: color)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// POLL SECTION
// ═══════════════════════════════════════════════════════════════════
class _PollSection extends StatelessWidget {
  final EventModel event;
  final List<VoteModel> votes;
  final String? userId;
  final String? selectedOption;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback? onVote;

  const _PollSection({
    required this.event,
    required this.votes,
    required this.userId,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalVotes = votes.length;
    final userVote = userId != null
        ? votes.where((v) => v.userId == userId).firstOrNull?.option
        : null;

    Map<String, int> voteCounts = {};
    for (final v in votes) {
      voteCounts[v.option] = (voteCounts[v.option] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.lgBorderRadius,
        boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.how_to_vote_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('التصويت',
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.primary)),
              const Spacer(),
              Text(
                '$totalVotes صوت',
                style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          ...event.pollOptions.map((option) {
            final count = voteCounts[option] ?? 0;
            final pct = totalVotes > 0 ? count / totalVotes : 0.0;
            final isUserChoice = userVote == option;
            final isSelected = selectedOption == option;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: userVote != null
                    ? null
                    : () => onOptionSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected || isUserChoice
                        ? AppColors.primary.withOpacity(0.08)
                        : (isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight),
                    borderRadius: AppRadius.mdBorderRadius,
                    border: Border.all(
                      color: isSelected || isUserChoice
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(option,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: isSelected || isUserChoice
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                )),
                          ),
                          if (userVote != null)
                            Text(
                              '${(pct * 100).toStringAsFixed(0)}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (isUserChoice)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 16),
                            ),
                        ],
                      ),
                      if (userVote != null) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: AppRadius.fullBorderRadius,
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.dividerLight,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          if (userVote == null && userId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton.primary(
              label: 'تأكيد التصويت',
              icon: Icons.how_to_vote_rounded,
              onPressed: selectedOption == null ? null : onVote,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COMMENTS SECTION
// ═══════════════════════════════════════════════════════════════════
class _CommentsSection extends StatelessWidget {
  final List<CommentModel> comments;
  final String? userId;
  final TextEditingController commentCtrl;
  final VoidCallback? onSubmit;

  const _CommentsSection({
    required this.comments,
    required this.userId,
    required this.commentCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.comment_outlined,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('التعليقات',
                style: AppTypography.titleSmall
                    .copyWith(color: AppColors.primary)),
            const Spacer(),
            Text(
              '${comments.length}',
              style: AppTypography.labelSmall.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariantLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Comment input
        if (userId != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  maxLines: null,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'اكتب تعليقك...',
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceVariantLight,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.lgBorderRadius,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: onSubmit,
                borderRadius: AppRadius.fullBorderRadius,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),

        const SizedBox(height: AppSpacing.md),

        // Comments list
        if (comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'لا توجد تعليقات بعد. كن أول من يعلّق!',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...comments.map((c) => _CommentTile(comment: c)),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              comment.userId.isNotEmpty
                  ? comment.userId[0].toUpperCase()
                  : 'م',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: isDark ? AppShadows.softDark : AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.content,
                      style: AppTypography.bodySmall.copyWith(height: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatRelative(comment.createdAt),
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
        ],
      ),
    );
  }
}
