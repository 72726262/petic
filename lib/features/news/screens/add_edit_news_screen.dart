import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/theme/app_colors.dart';
import 'package:employee_portal/core/theme/app_typography.dart';
import 'package:employee_portal/core/theme/app_spacing.dart';
import 'package:employee_portal/core/theme/app_radius.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/core/utils/app_strings.dart';
import 'package:employee_portal/core/error_handling/error_handler.dart';
import 'package:employee_portal/features/auth/cubit/auth_cubit.dart';
import 'package:employee_portal/features/auth/cubit/auth_state.dart';
import 'package:employee_portal/features/news/cubit/news_cubit.dart';
import 'package:employee_portal/features/news/cubit/news_state.dart';
import 'package:employee_portal/features/news/services/news_service.dart';
import 'package:employee_portal/shared/widgets/app_button.dart';
import 'package:employee_portal/shared/widgets/app_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddEditNewsScreen extends StatefulWidget {
  final String? newsId;

  const AddEditNewsScreen({super.key, this.newsId});

  @override
  State<AddEditNewsScreen> createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  String? _imageUrl;
  bool _uploadingImage = false;

  bool get _isEditing => widget.newsId != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ─── Upload image to Supabase Storage ─────────────────────────────
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingImage = true);
    try {
      final bytes = await picked.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final path = 'news/$fileName';

      await Supabase.instance.client.storage
          .from(AppConstants.newsBucket)
          .uploadBinary(path, bytes);

      final url = Supabase.instance.client.storage
          .from(AppConstants.newsBucket)
          .getPublicUrl(path);

      setState(() => _imageUrl = url);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(
            context, AppStrings.of(context).isAr ? 'فشل رفع الصورة. حاول مجددًا.' : 'Image upload failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  // ─── Submit form ───────────────────────────────────────────────────
  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final cubit = context.read<NewsCubit>();

    if (_isEditing) {
      cubit.updateNews(
        id: widget.newsId!,
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim().isEmpty
            ? null
            : _subtitleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        imageUrl: _imageUrl,
      );
    } else {
      cubit.createNews(
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim().isEmpty
            ? null
            : _subtitleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        imageUrl: _imageUrl,
        authorId: authState.user.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) {
        final cubit = NewsCubit(newsService: NewsService());
        if (_isEditing) cubit.loadNewsDetail(widget.newsId!);
        return cubit;
      },
      child: BlocConsumer<NewsCubit, NewsState>(
        listener: (context, state) {
          if (state is NewsError) {
            ErrorHandler.showErrorSnackbar(context, state.message);
          }
          if (state is NewsActionSuccess) {
            ErrorHandler.showSuccessSnackbar(context, state.message);
            Navigator.of(context).pop(true);
          }
          // Pre-fill fields when editing
          if (state is NewsDetailLoaded && _isEditing) {
            _titleCtrl.text = state.news.title;
            _subtitleCtrl.text = state.news.subtitle ?? '';
            _contentCtrl.text = state.news.content ?? '';
            setState(() => _imageUrl = state.news.imageUrl);
          }
        },
        builder: (context, state) {
          final isLoading = state is NewsLoading;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Builder(builder: (ctx) {
                final s = AppStrings.of(ctx);
                return Text(
                  _isEditing ? s.editNews : s.addNews,
                  style: AppTypography.titleMedium,
                );
              }),
              centerTitle: true,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // ─── Image Picker ─────────────────────────────────
                  _buildImagePicker(isDark),
                  const SizedBox(height: AppSpacing.xl),

                  Builder(builder: (ctx) {
                    final s = AppStrings.of(ctx);
                    return Column(
                      children: [
                        AppTextField(
                          controller: _titleCtrl,
                          label: s.newsTitle,
                          hint: s.isAr ? 'أدخل عنوان الخبر' : 'Enter news title',
                          prefixIcon: const Icon(Icons.title_rounded),
                          validator: (v) =>
                              v == null || v.isEmpty ? (s.isAr ? 'العنوان مطلوب' : 'Title is required') : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _subtitleCtrl,
                          label: s.isAr ? 'ملخص (اختياري)' : 'Summary (optional)',
                          hint: s.isAr ? 'ملخص مختصر للخبر' : 'Brief summary',
                          prefixIcon: const Icon(Icons.short_text_rounded),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _contentCtrl,
                          label: s.newsContent,
                          hint: s.isAr ? 'اكتب محتوى الخبر هنا...' : 'Write news content here...',
                          prefixIcon: const Icon(Icons.article_outlined),
                          maxLines: 10,
                          validator: (v) =>
                              v == null || v.isEmpty ? (s.isAr ? 'المحتوى مطلوب' : 'Content is required') : null,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton.primary(
                          label: _isEditing ? s.saveChanges : (s.isAr ? 'نشر الخبر' : 'Publish'),
                          icon: _isEditing ? Icons.save_rounded : Icons.publish_rounded,
                          isLoading: isLoading,
                          onPressed: () => _submit(context),
                        ),
                        const SizedBox(height: AppSpacing.massive),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Image Picker Widget ───────────────────────────────────────────
  Widget _buildImagePicker(bool isDark) {
    return GestureDetector(
      onTap: _uploadingImage ? null : _pickAndUploadImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: _imageUrl != null
                ? AppColors.primary.withOpacity(0.4)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: 2,
          ),
        ),
        child: _imageUrl != null
            ? ClipRRect(
                borderRadius: AppRadius.lgBorderRadius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: AppRadius.fullBorderRadius,
                          ),
                          child: Text(
                            AppStrings.of(context).isAr ? 'اضغط لتغيير الصورة' : 'Tap to change image',
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _uploadingImage
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.of(context).isAr ? 'اضغط لإضافة صورة' : 'Tap to add an image',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.of(context).isAr ? 'اختياري' : 'Optional',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariantLight,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
