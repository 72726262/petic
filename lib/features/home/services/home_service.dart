import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/news/models/news_model.dart';
import 'package:employee_portal/features/events/models/event_model.dart';
import 'package:employee_portal/features/home/cubit/home_state.dart';

/// Service for fetching Home screen data
class HomeService {
  final SupabaseClient _client;

  HomeService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<HomeData> fetchHomeData() async {
    try {
      // Fetch latest news (limit 5)
      final newsData = await _client
          .from(AppConstants.newsTable)
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      // Fetch upcoming events (today and future)
      // Use date-only format because the `date` column is Postgres 'date' type
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final eventsData = await _client
          .from(AppConstants.eventsTable)
          .select()
          .gte('date', todayStr)
          .order('date', ascending: true)
          .limit(5);

      // Fetch latest CEO message
      final ceoData = await _client
          .from(AppConstants.ceoMessagesTable)
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return HomeData(
        latestNews: (newsData as List)
            .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        upcomingEvents: (eventsData as List)
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        ceoMessage: ceoData != null ? ceoData['body'] as String? : null,
        ceoMessageVisible: ceoData != null,
      );
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'فشل جلب بيانات الرئيسية.',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw UnknownException(
        message: 'حدث خطأ أثناء تحميل الرئيسية.',
        originalError: e,
      );
    }
  }
}
