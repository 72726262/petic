import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/events/models/event_model.dart';

class EventService {
  final SupabaseClient _client;

  EventService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ─── Fetch All Events ──────────────────────────────────────────────
  Future<List<EventModel>> fetchEvents({int limit = 20}) async {
    try {
      // Use date-only so it compares correctly with Postgres 'date' column
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final data = await _client
          .from(AppConstants.eventsTable)
          .select()
          .gte('date', todayStr)
          .order('date', ascending: true)
          .limit(limit);

      return (data as List)
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل تحميل الفعاليات.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Fetch Single Event ────────────────────────────────────────────
  Future<EventModel> fetchEventById(String id) async {
    try {
      final data = await _client
          .from(AppConstants.eventsTable)
          .select()
          .eq('id', id)
          .single();
      return EventModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل تحميل الفعالية.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Fetch Votes for Event ─────────────────────────────────────────
  Future<List<VoteModel>> fetchVotes(String eventId) async {
    try {
      final data = await _client
          .from(AppConstants.eventVotesTable)
          .select()
          .eq('event_id', eventId);
      return (data as List)
          .map((e) => VoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Fetch Comments for Event ──────────────────────────────────────
  Future<List<CommentModel>> fetchComments(String eventId) async {
    try {
      final data = await _client
          .from(AppConstants.commentsTable)
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: true);
      return (data as List)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Submit Vote ───────────────────────────────────────────────────
  Future<void> submitVote({
    required String eventId,
    required String userId,
    required String option,
  }) async {
    try {
      // Upsert: one vote per user per event (no update allowed by RLS)
      await _client.from(AppConstants.eventVotesTable).insert({
        'event_id': eventId,
        'user_id': userId,
        'option': option,
      });
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل تسجيل التصويت.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Add Comment ───────────────────────────────────────────────────
  Future<void> addComment({
    required String eventId,
    required String userId,
    required String comment,
  }) async {
    try {
      await _client.from(AppConstants.commentsTable).insert({
        'event_id': eventId,
        'user_id': userId,
        'content': comment,
      });
    } on PostgrestException catch (e) {
      throw ServerException(
          message: 'فشل إضافة التعليق.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }

  // ─── Realtime Events Stream ────────────────────────────────────────
  Stream<List<EventModel>> eventsStream() {
    return _client
        .from(AppConstants.eventsTable)
        .stream(primaryKey: ['id'])
        .order('date', ascending: true)
        .map((data) =>
            data.map((e) => EventModel.fromJson(e)).toList());
  }
}
