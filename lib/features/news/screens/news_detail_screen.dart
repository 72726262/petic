import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/core/utils/app_utils.dart';
import 'package:employee_portal/core/utils/app_strings.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/news/cubit/news_cubit.dart';
import 'package:employee_portal/features/news/cubit/news_state.dart';
import 'package:employee_portal/features/news/services/news_service.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsCubit(newsService: NewsService())
        ..loadNewsDetail(newsId),
      child: _NewsDetailView(newsId: newsId),
    );
  }
}

class _NewsDetailView extends StatelessWidget {
  final String newsId;
  const _NewsDetailView({required this.newsId});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsDetailLoading || state is NewsInitial) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const LoadingWidget(),
          );
        }

        if (state is NewsError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<NewsCubit>().loadNewsDetail(newsId),
            ),
          );
        }

        if (state is NewsDetailLoaded) {
          final news = state.news;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // ─── SliverAppBar with Hero Image ───────────────────
                SliverAppBar(
                  expandedHeight: news.imageUrl != null ? 280 : 100,
                  pinned: true,
                  stretch: true,
                  backgroundColor: AppColors.backgroundDark,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  actions: [
                    if (isAdmin)
                      GestureDetector(
                        onTap: () => context.push(
                          '${RouteNames.newsList}/edit/${news.id}',
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.edit_outlined,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: news.imageUrl != null
                        ? Hero(
                            tag: 'news-image-${news.id}',
                            child: CachedNetworkImage(
                              imageUrl: news.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorWidget: (_, __, ___) =>
                                  _DetailImagePlaceholder(),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Center(
                              child: Icon(Icons.newspaper_outlined,
                                  color: Colors.white, size: 56),
                            ),
                          ),
                  ),
                ),

                // ─── Content ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -20, 0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.xxl,
                          AppSpacing.lg, AppSpacing.huge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.newsColorLight,
                              borderRadius: AppRadius.fullBorderRadius,
                            ),
                            child: Text(
                              AppStrings.of(context).isAr ? 'خبر' : 'News',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.newsColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Title
                          Text(
                            news.title,
                            style: AppTypography.headlineSmall.copyWith(
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Date
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 14,
                                  color: AppColors.onSurfaceVariantLight),
                              const SizedBox(width: 4),
                              Text(
                                AppUtils.formatDateTime(news.createdAt),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariantLight,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Divider
                          Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Subtitle
                          if (news.subtitle != null) ...[
                            Text(
                              news.subtitle!,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.onSurfaceVariantLight,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // Body content
                          if (news.content != null)
                            SelectableText(
                              news.content!,
                              style: AppTypography.bodyLarge.copyWith(
                                height: 1.8,
                              ),
                            ),

                          const SizedBox(height: AppSpacing.huge),
                        ],
                      ),
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

class _DetailImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Center(
        child:
            Icon(Icons.newspaper_outlined, color: Colors.white, size: 56),
      ),
    );
  }
}
