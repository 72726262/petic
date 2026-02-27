import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_portal/core/error_handling/app_exception.dart';
import 'package:employee_portal/core/utils/app_constants.dart';
import 'package:employee_portal/features/it/models/it_content_model.dart';

class ITService {
  final SupabaseClient _client;
  ITService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<ITContentModel>> fetchAll() async {
    try {
      final data = await _client
          .from(AppConstants.itContentTable)
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => ITContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل تحميل بيانات تقنية المعلومات.', code: e.code, originalError: e);
    } catch (e) {
      throw UnknownException(message: 'خطأ غير متوقع.', originalError: e);
    }
  }
}
