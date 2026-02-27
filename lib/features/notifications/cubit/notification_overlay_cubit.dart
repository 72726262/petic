import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/features/notifications/models/notification_overlay_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────
abstract class NotificationOverlayState {}

class NotificationOverlayInitial extends NotificationOverlayState {}

class NotificationOverlayReceived extends NotificationOverlayState {
  final NotificationOverlayModel notification;
  NotificationOverlayReceived(this.notification);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────
class NotificationOverlayCubit extends Cubit<NotificationOverlayState> {
  final SupabaseClient _client;

  final List<RealtimeChannel> _channels = [];

  NotificationOverlayCubit({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client,
        super(NotificationOverlayInitial());

  /// Call this once the user is authenticated
  void startListening() {
    _stopAll();

    // ── News ──────────────────────────────────────────────────────────
    final newsChannel = _client
        .channel('public:news:insert')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'news',
          callback: (payload) {
            final row = payload.newRecord;
            emit(NotificationOverlayReceived(
              NotificationOverlayModel.news(
                id: row['id'] as String? ?? '',
                title: row['title'] as String? ?? 'خبر جديد',
              ),
            ));
          },
        )
        .subscribe();
    _channels.add(newsChannel);

    // ── Events ────────────────────────────────────────────────────────
    final eventsChannel = _client
        .channel('public:events:insert')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'events',
          callback: (payload) {
            final row = payload.newRecord;
            emit(NotificationOverlayReceived(
              NotificationOverlayModel.event(
                id: row['id'] as String? ?? '',
                title: row['title'] as String? ?? 'فعالية جديدة',
              ),
            ));
          },
        )
        .subscribe();
    _channels.add(eventsChannel);

    // ── HR Content ────────────────────────────────────────────────────
    final hrChannel = _client
        .channel('public:hr_content:insert')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'hr_content',
          callback: (payload) {
            final row = payload.newRecord;
            emit(NotificationOverlayReceived(
              NotificationOverlayModel.hr(
                id: row['id'] as String? ?? '',
                title: row['title'] as String? ?? 'تحديث جديد',
              ),
            ));
          },
        )
        .subscribe();
    _channels.add(hrChannel);

    // ── IT Content ────────────────────────────────────────────────────
    final itChannel = _client
        .channel('public:it_content:insert')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'it_content',
          callback: (payload) {
            final row = payload.newRecord;
            emit(NotificationOverlayReceived(
              NotificationOverlayModel.it(
                id: row['id'] as String? ?? '',
                title: row['title'] as String? ?? 'تحديث جديد',
              ),
            ));
          },
        )
        .subscribe();
    _channels.add(itChannel);
  }

  void _stopAll() {
    for (final ch in _channels) {
      _client.removeChannel(ch);
    }
    _channels.clear();
  }

  @override
  Future<void> close() {
    _stopAll();
    return super.close();
  }
}
