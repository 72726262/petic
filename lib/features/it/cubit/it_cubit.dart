import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/it/cubit/it_state.dart';
import 'package:employee_portal/features/it/models/it_content_model.dart';
import 'package:employee_portal/features/it/services/it_service.dart';

class ITCubit extends Cubit<ITState> {
  final ITService _itService;

  ITCubit({required ITService itService})
      : _itService = itService,
        super(const ITInitial());

  Future<void> loadAll() async {
    emit(const ITLoading());
    try {
      final all = await _itService.fetchAll();

      emit(ITLoaded(
        alerts: all.where((e) => e.category == ITCategory.alert).toList(),
        tips: all.where((e) => e.category == ITCategory.tip).toList(),
        policies: all.where((e) => e.category == ITCategory.policy).toList(),
        guides: all.where((e) => e.category == ITCategory.guide).toList(),
      ));
    } on AppException catch (e) {
      emit(ITError(message: e.message));
    } catch (_) {
      emit(const ITError(message: 'فشل تحميل بيانات تقنية المعلومات.'));
    }
  }
}
