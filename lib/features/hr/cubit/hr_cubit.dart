import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/hr/cubit/hr_state.dart';
import 'package:employee_portal/features/hr/models/hr_content_model.dart';
import 'package:employee_portal/features/hr/services/hr_service.dart';

class HRCubit extends Cubit<HRState> {
  final HRService _hrService;

  HRCubit({required HRService hrService})
      : _hrService = hrService,
        super(const HRInitial());

  Future<void> loadAll() async {
    emit(const HRLoading());
    try {
      final all = await _hrService.fetchAll();

      emit(HRLoaded(
        policies: all.where((e) => e.category == HRCategory.policy).toList(),
        trainings: all.where((e) => e.category == HRCategory.training).toList(),
        jobs: all.where((e) => e.category == HRCategory.job).toList(),
      ));
    } on AppException catch (e) {
      emit(HRError(message: e.message));
    } catch (_) {
      emit(const HRError(message: 'فشل تحميل بيانات الموارد البشرية.'));
    }
  }
}
