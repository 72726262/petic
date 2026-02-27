import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/news/cubit/news_state.dart';
import 'package:employee_portal/features/news/services/news_service.dart';
import 'package:employee_portal/features/news/models/news_model.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsService _newsService;
  StreamSubscription? _realtimeSub;

  NewsCubit({required NewsService newsService})
      : _newsService = newsService,
        super(const NewsInitial());

  // ─── Load news list ────────────────────────────────────────────────
  Future<void> loadNews() async {
    emit(const NewsLoading());
    try {
      final news = await _newsService.fetchNews();
      emit(NewsLoaded(news: news));
    } on AppException catch (e) {
      emit(NewsError(message: e.message));
    } catch (_) {
      emit(const NewsError(message: 'فشل تحميل الأخبار.'));
    }
  }

  // ─── Subscribe to Realtime updates ────────────────────────────────
  void subscribeToRealtime() {
    _realtimeSub?.cancel();
    _realtimeSub = _newsService.newsStream().listen(
      (news) => emit(NewsLoaded(news: news)),
      onError: (_) {},
    );
  }

  // ─── Load single news detail ───────────────────────────────────────
  Future<void> loadNewsDetail(String id) async {
    emit(const NewsDetailLoading());
    try {
      final news = await _newsService.fetchNewsById(id);
      emit(NewsDetailLoaded(news: news));
    } on AppException catch (e) {
      emit(NewsError(message: e.message));
    } catch (_) {
      emit(const NewsError(message: 'فشل تحميل الخبر.'));
    }
  }

  // ─── Create news ───────────────────────────────────────────────────
  Future<void> createNews({
    required String title,
    String? subtitle,
    required String content,
    String? imageUrl,
    required String authorId,
  }) async {
    emit(const NewsLoading());
    try {
      await _newsService.createNews(
        title: title,
        subtitle: subtitle,
        content: content,
        imageUrl: imageUrl,
        authorId: authorId,
      );
      emit(const NewsActionSuccess(message: 'تم إضافة الخبر بنجاح.'));
      await loadNews();
    } on AppException catch (e) {
      emit(NewsError(message: e.message));
    } catch (_) {
      emit(const NewsError(message: 'فشل إضافة الخبر.'));
    }
  }

  // ─── Update news ───────────────────────────────────────────────────
  Future<void> updateNews({
    required String id,
    String? title,
    String? subtitle,
    String? content,
    String? imageUrl,
  }) async {
    emit(const NewsLoading());
    try {
      await _newsService.updateNews(
        id: id,
        title: title,
        subtitle: subtitle,
        content: content,
        imageUrl: imageUrl,
      );
      emit(const NewsActionSuccess(message: 'تم تحديث الخبر بنجاح.'));
      await loadNews();
    } on AppException catch (e) {
      emit(NewsError(message: e.message));
    } catch (_) {
      emit(const NewsError(message: 'فشل تحديث الخبر.'));
    }
  }

  // ─── Delete news ───────────────────────────────────────────────────
  Future<void> deleteNews(String id) async {
    try {
      await _newsService.deleteNews(id);
      emit(const NewsActionSuccess(message: 'تم حذف الخبر.'));
      await loadNews();
    } on AppException catch (e) {
      emit(NewsError(message: e.message));
    } catch (_) {
      emit(const NewsError(message: 'فشل حذف الخبر.'));
    }
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
