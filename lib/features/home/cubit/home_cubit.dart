import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/features/auth/models/user_model.dart';
import 'package:employee_portal/features/home/cubit/home_state.dart';
import 'package:employee_portal/features/home/services/home_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService _homeService;

  HomeCubit({required HomeService homeService})
      : _homeService = homeService,
        super(const HomeInitial());

  Future<void> loadHome() async {
    emit(const HomeLoading());
    try {
      final data = await _homeService.fetchHomeData();
      emit(HomeLoaded(data: data));
    } on AppException catch (e) {
      emit(HomeError(message: e.message));
    } catch (e) {
      emit(const HomeError(message: 'فشل تحميل الصفحة الرئيسية.'));
    }
  }

  Future<void> refresh() async {
    await loadHome();
  }

  void clear() {
    emit(const HomeInitial());
  }
}
