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
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/news/cubit/news_cubit.dart';
import 'package:employee_portal/features/news/cubit/news_state.dart';
import 'package:employee_portal/features/news/models/news_model.dart';
import 'package:employee_portal/features/news/services/news_service.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:employee_portal/shared/widgets/date_filter_bar.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsCubit(newsService: NewsService())
        ..loadNews()
        ..subscribeToRealtime(),
      child: const _NewsListView(),
    );
  }
}

class _NewsListView extends StatefulWidget {
  const _NewsListView();

  @override
  State<_NewsListView> createState() => _NewsListViewState();
}

class _NewsListViewState extends State<_NewsListView> {
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    return BlocConsumer<NewsCubit, NewsState>(
      listener: (context, state) {
        if (state is NewsError) {
          ErrorHandler.showErrorSnackbar(context, state.message);
        }
        if (state is NewsActionSuccess) {
          ErrorHandler.showSuccessSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'الأخبار',
            showBack: true,
            actions: [
              // Realtime indicator
              if (state is NewsLoaded)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مباشر',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => context.push('${RouteNames.newsList}/add'),
                ),
            ],
          ),
          body: Column(
            children: [
              DateFilterBar(
                selectedDate: _filterDate,
                accentColor: AppColors.newsColor,
                onDateChanged: (d) => setState(() => _filterDate = d),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NewsState state) {
    if (state is NewsLoading || state is NewsInitial) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      );
    }

    if (state is NewsError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () => context.read<NewsCubit>().loadNews(),
      );
    }

    if (state is NewsLoaded) {
      final filtered = _filterDate == null
          ? state.news
          : state.news
              .where((n) => matchesDateFilter(n.createdAt, _filterDate))
              .toList();

      if (filtered.isEmpty) {
        return EmptyStateWidget(
          title: _filterDate == null ? 'لا توجد أخبار' : 'لا توجد أخبار في هذا اليوم',
          subtitle: _filterDate == null
              ? 'لم يتم نشر أي أخبار بعد.'
              : 'جرّب تاريخاً آخر أو اعرض كل الأخبار.',
          icon: Icons.newspaper_outlined,
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<NewsCubit>().loadNews(),
        color: AppColors.newsColor,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => _NewsCard(
            news: filtered[index],
            index: index,
            onTap: () => context.push(
              '${RouteNames.newsList}/${filtered[index].id}',
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ═══════════════════════════════════════════════════════════════════
// NEWS CARD
// ═══════════════════════════════════════════════════════════════════
class _NewsCard extends StatelessWidget {
  final NewsModel news;
  final int index;
  final VoidCallback onTap;

  const _NewsCard(
      {required this.news, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              if (news.imageUrl != null)
                Hero(
                  tag: 'news-image-${news.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: news.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _ImagePlaceholder(height: 200),
                      errorWidget: (_, __, ___) =>
                          _ImagePlaceholder(height: 200),
                    ),
                  ),
                )
              else
                _ImagePlaceholder(height: 160, useGradient: true),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // News tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.newsColorLight,
                        borderRadius: AppRadius.fullBorderRadius,
                      ),
                      child: Text(
                        'خبر',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.newsColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Title
                    Text(
                      news.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Subtitle
                    if (news.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        news.subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),

                    // Footer: date + read more
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.formatRelative(news.createdAt),
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceVariantDark
                                : AppColors.onSurfaceVariantLight,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'اقرأ المزيد →',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final bool useGradient;

  const _ImagePlaceholder({required this.height, this.useGradient = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer,
        gradient: useGradient ? AppColors.primaryGradient : null,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Icon(
        Icons.newspaper_outlined,
        color: useGradient ? Colors.white.withOpacity(0.5) : AppColors.primary,
        size: 48,
      ),
    );
  }
}
