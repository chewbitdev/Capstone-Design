import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/emergency_event_model.dart';
import '../models/guardian_model.dart';
import '../models/user_profile_model.dart';
import '../models/vital_model.dart';
import '../../../../core/network/api_client.dart';

class DependentRepository {
  final Dio _dio = createDio();

  Future<UserProfileModel> getUserProfile(int userId) async {
    final response = await _dio.get('/api/users/$userId/main');
    return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EmergencyEventModel?> getEmergencyEvent(int userId) async {
    final response = await _dio.get('/api/emergency_event/$userId/emergency');
    if (response.data == null) return null;
    return EmergencyEventModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<GuardianModel>> getGuardians(int userId) async {
    final response = await _dio.get(
      '/guardians',
      queryParameters: {'userId': userId},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => GuardianModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Stream<VitalModel> streamVitals(int userId) async* {
    final response = await _dio.get(
      '/api/vitals/stream/$userId',
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
      ),
    );

    final stream = (response.data as ResponseBody).stream;
    var buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);

      while (buffer.contains('\n\n')) {
        final idx = buffer.indexOf('\n\n');
        final event = buffer.substring(0, idx);
        buffer = buffer.substring(idx + 2);

        for (final line in event.split('\n')) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isNotEmpty && jsonStr != 'null') {
              try {
                yield VitalModel.fromJson(
                  json.decode(jsonStr) as Map<String, dynamic>,
                );
              } catch (_) {}
            }
          }
        }
      }
    }
  }
}
