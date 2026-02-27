import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/mood/cubit/mood_state.dart';
import 'package:employee_portal/features/mood/models/mood_model.dart';
import 'package:employee_portal/features/mood/services/mood_service.dart';

class MoodCubit extends Cubit<MoodState> {
  final MoodService _moodService;

  MoodCubit({required MoodService moodService})
      : _moodService = moodService,
        super(const MoodInitial());

  Future<void> loadMoods(String userId) async {
    emit(const MoodLoading());
    try {
      final results = await Future.wait([
        _moodService.fetchHistory(userId),
        _moodService.fetchTodayMood(userId),
      ]);
      emit(MoodLoaded(
        history: results[0] as List<MoodModel>,
        todayMood: results[1] as MoodModel?,
      ));
    } on AppException catch (e) {
      emit(MoodError(message: e.message));
    } catch (_) {
      emit(const MoodError(message: 'فشل تحميل سجل المزاج.'));
    }
  }

  Future<void> submitMood({
    required String userId,
    required MoodLevel mood,
    String? note,
  }) async {
    emit(const MoodSubmitting());
    try {
      await _moodService.submitMood(userId: userId, mood: mood, note: note);
      emit(const MoodSubmitSuccess());
      await loadMoods(userId);
    } on AppException catch (e) {
      emit(MoodError(message: e.message));
    } catch (_) {
      emit(const MoodError(message: 'فشل تسجيل المزاج.'));
    }
  }
}
