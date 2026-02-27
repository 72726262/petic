import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/events/cubit/event_state.dart';
import 'package:employee_portal/features/events/services/event_service.dart';

class EventCubit extends Cubit<EventState> {
  final EventService _eventService;
  StreamSubscription? _realtimeSub;

  EventCubit({required EventService eventService})
      : _eventService = eventService,
        super(const EventInitial());

  // ─── Load events list ──────────────────────────────────────────────
  Future<void> loadEvents() async {
    emit(const EventLoading());
    try {
      final events = await _eventService.fetchEvents();
      emit(EventsLoaded(events: events));
    } on AppException catch (e) {
      emit(EventError(message: e.message));
    } catch (_) {
      emit(const EventError(message: 'فشل تحميل الفعاليات.'));
    }
  }

  // ─── Realtime subscription ─────────────────────────────────────────
  void subscribeToRealtime() {
    _realtimeSub?.cancel();
    _realtimeSub = _eventService.eventsStream().listen(
      (events) => emit(EventsLoaded(events: events)),
      onError: (_) {},
    );
  }

  // ─── Load event detail (event + votes + comments) ──────────────────
  Future<void> loadEventDetail(String id) async {
    emit(const EventDetailLoading());
    try {
      final results = await Future.wait([
        _eventService.fetchEventById(id),
        _eventService.fetchVotes(id),
        _eventService.fetchComments(id),
      ]);

      emit(EventDetailLoaded(
        event: results[0] as dynamic,
        votes: results[1] as dynamic,
        comments: results[2] as dynamic,
      ));
    } on AppException catch (e) {
      emit(EventError(message: e.message));
    } catch (_) {
      emit(const EventError(message: 'فشل تحميل الفعالية.'));
    }
  }

  // ─── Submit vote ───────────────────────────────────────────────────
  Future<void> submitVote({
    required String eventId,
    required String userId,
    required String option,
  }) async {
    try {
      await _eventService.submitVote(
          eventId: eventId, userId: userId, option: option);
      emit(const EventActionSuccess(message: 'تم تسجيل تصويتك.'));
      await loadEventDetail(eventId);
    } on AppException catch (e) {
      emit(EventError(message: e.message));
    } catch (_) {
      emit(const EventError(message: 'فشل تسجيل التصويت.'));
    }
  }

  // ─── Add comment ───────────────────────────────────────────────────
  Future<void> addComment({
    required String eventId,
    required String userId,
    required String comment,
  }) async {
    try {
      await _eventService.addComment(
          eventId: eventId, userId: userId, comment: comment);
      await loadEventDetail(eventId);
    } on AppException catch (e) {
      emit(EventError(message: e.message));
    } catch (_) {
      emit(const EventError(message: 'فشل إضافة التعليق.'));
    }
  }

  @override
  Future<void> close() {
    _realtimeSub?.cancel();
    return super.close();
  }
}
