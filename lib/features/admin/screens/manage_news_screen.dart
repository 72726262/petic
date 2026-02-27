import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:employee_portal/core/router/route_names.dart';
import 'package:employee_portal/features/news/models/news_model.dart';
import 'package:employee_portal/shared/widgets/custom_app_bar.dart';
import 'package:employee_portal/shared/widgets/loading_widget.dart';
import 'package:employee_portal/shared/widgets/state_widgets.dart';

class ManageNewsScreen extends StatefulWidget {
  const ManageNewsScreen({super.key});

  @override
  State<ManageNewsScreen> createState() => _ManageNewsScreenState();
}

class _ManageNewsScreenState extends State<ManageNewsScreen> {
  final _client = Supabase.instance.client;
  List<NewsModel> _news = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _loading = true);
    try {
      final data = await _client
          .from(AppConstants.newsTable)
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _news = (data as List)
            .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, 'فشل تحميل الأخبار.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteNews(String id) async {
    final confirmed = await _showDeleteConfirm('هل تريد حذف هذا الخبر؟');
    if (!confirmed) return;

    try {
      await _client.from(AppConstants.newsTable).delete().eq('id', id);
      ErrorHandler.showSuccessSnackbar(context, 'تم حذف الخبر.');
      _fetchNews();
    } catch (_) {
      ErrorHandler.showErrorSnackbar(context, 'فشل حذف الخبر.');
    }
  }

  Future<bool> _showDeleteConfirm(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('حذف',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة الأخبار',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(RouteNames.addNews);
          _fetchNews();
        },
        backgroundColor: AppColors.newsColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('خبر جديد',
            style: AppTypography.labelMedium.copyWith(color: Colors.white)),
      ),
      body: _loading
          ? const LoadingWidget()
          : _news.isEmpty
              ? const EmptyStateWidget(
                  title: 'لا توجد أخبار منشورة.',
                  icon: Icons.newspaper_outlined)
              : RefreshIndicator(
                  onRefresh: _fetchNews,
                  color: AppColors.newsColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
                    itemCount: _news.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final news = _news[index];
                      return StaggeredListItem(
                        index: index,
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
                              // News thumbnail
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.newsColor.withOpacity(0.12),
                                  borderRadius: AppRadius.mdBorderRadius,
                                  image: news.imageUrl != null
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(news.imageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: news.imageUrl == null
                                    ? const Icon(Icons.newspaper_outlined,
                                        color: AppColors.newsColor, size: 28)
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.md),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(news.title,
                                        style: AppTypography.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppUtils.formatRelative(
                                          news.createdAt),
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isDark
                                            ? AppColors.onSurfaceVariantDark
                                            : AppColors.onSurfaceVariantLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Actions
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20),
                                color: AppColors.primary,
                                onPressed: () async {
                                  await context.push(
                                      '/news/edit/${news.id}');
                                  _fetchNews();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 20),
                                color: AppColors.error,
                                onPressed: () => _deleteNews(news.id),
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
