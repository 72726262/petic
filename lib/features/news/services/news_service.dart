import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/news/models/news_model.dart';

class NewsService {
  final SupabaseClient _client;

  NewsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ─── Fetch All News ────────────────────────────────────────────────
  Future<List<NewsModel>> fetchNews({int limit = 20, int offset = 0}) async {
    try {
      final data = await _client
          .from(AppConstants.newsTable)
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحميل الأخبار.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Fetch Single News ─────────────────────────────────────────────
  Future<NewsModel> fetchNewsById(String id) async {
    try {
      final data = await _client
          .from(AppConstants.newsTable)
          .select()
          .eq('id', id)
          .single();

      return NewsModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحميل تفاصيل الخبر.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Create News ───────────────────────────────────────────────────
  Future<NewsModel> createNews({
    required String title,
    String? subtitle,
    required String content,
    String? imageUrl,
    required String authorId,
  }) async {
    try {
      final data = await _client
          .from(AppConstants.newsTable)
          .insert({
            'title': title,
            'subtitle': subtitle,
            'content': content,
            'image_url': imageUrl,
            'author_id': authorId,
          })
          .select()
          .single();

      return NewsModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل إضافة الخبر.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Update News ───────────────────────────────────────────────────
  Future<NewsModel> updateNews({
    required String id,
    String? title,
    String? subtitle,
    String? content,
    String? imageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (subtitle != null) updates['subtitle'] = subtitle;
      if (content != null) updates['content'] = content;
      if (imageUrl != null) updates['image_url'] = imageUrl;

      final data = await _client
          .from(AppConstants.newsTable)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return NewsModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحديث الخبر.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Delete News ───────────────────────────────────────────────────
  Future<void> deleteNews(String id) async {
    try {
      await _client.from(AppConstants.newsTable).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل حذف الخبر.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Realtime Stream ───────────────────────────────────────────────
  Stream<List<NewsModel>> newsStream() {
    return _client
        .from(AppConstants.newsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .map((e) => NewsModel.fromJson(e))
            .toList());
  }
}
