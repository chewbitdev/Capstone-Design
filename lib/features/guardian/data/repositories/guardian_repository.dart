import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/ward.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../domain/entities/biometric_data.dart';
import '../models/ward_detail_model.dart';
import '../models/notification_model.dart';
import '../models/event_detail_model.dart';

class GuardianRepository {
  final Dio _dio = createDio();

  // ── 피보호자 목록 ──────────────────────────────────────────────────────────

  /// GET /api/v1/guardians/me/users — 한 번 호출로 Ward + BiometricData 추출
  Future<(List<Ward>, Map<String, BiometricData>)> fetchUsersAndBiometrics() async {
    final response = await _dio.get('/api/v1/guardians/me/users');
    final apiData = response.data as Map<String, dynamic>;
    final inner = apiData['data'] as Map<String, dynamic>? ?? {};
    final users = (inner['users'] as List<dynamic>? ?? []);

    final wards = <Ward>[];
    final biometrics = <String, BiometricData>{};

    for (final u in users) {
      final card = u as Map<String, dynamic>;
      final ward = _cardToWard(card);
      wards.add(ward);
      biometrics[ward.id] = _cardToBiometric(card, ward.id);
    }
    return (wards, biometrics);
  }

  /// GET /api/v1/guardians/me/users/{userId} — 단일 피보호자 상세
  Future<WardDetailModel> getUserStateDetail(int userId) async {
    final response = await _dio.get('/api/v1/guardians/me/users/$userId');
    final apiData = response.data as Map<String, dynamic>;
    final inner = apiData['data'] as Map<String, dynamic>? ?? apiData;
    return WardDetailModel.fromJson(inner);
  }

  // ── 긴급 이벤트 ────────────────────────────────────────────────────────────

  /// GET /api/emergency_event/alerts
  Future<List<EmergencyAlert>> fetchAlerts() async {
    final response = await _dio.get('/api/emergency_event/alerts');
    final data = response.data as Map<String, dynamic>;
    final alerts = (data['alerts'] as List<dynamic>? ?? []);
    return alerts
        .map((e) => _alertToEntity(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/emergency_event/{eventId}/detail
  Future<EventDetailModel> getEmergencyEventDetail(int eventId) async {
    final response =
        await _dio.get('/api/emergency_event/$eventId/detail');
    return EventDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/emergency_event/{eventId}/resolve
  Future<void> resolveEvent(int eventId) async {
    await _dio.patch('/api/emergency_event/$eventId/resolve');
  }

  /// PATCH /api/emergency_event/resolve-all
  Future<void> resolveAllEvents() async {
    await _dio.patch('/api/emergency_event/resolve-all');
  }

  // ── 알림 ───────────────────────────────────────────────────────────────────

  /// GET /api/v1/notifications
  Future<List<NotificationModel>> getNotifications({
    String? status,
    int page = 1,
    int size = 50,
  }) async {
    final response = await _dio.get(
      '/api/v1/notifications',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'size': size,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final list = (data['notifications'] as List<dynamic>? ?? []);
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/notifications/unread-count
  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/v1/notifications/unread-count');
    return (response.data as num).toInt();
  }

  /// PATCH /api/v1/notifications/{notificationId}/read
  Future<void> markNotificationRead(int notificationId) async {
    await _dio.patch('/api/v1/notifications/$notificationId/read');
  }

  // ── 초대 ───────────────────────────────────────────────────────────────────

  /// GET /api/v1/guardians/me/invitations
  Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    final response = await _dio.get('/api/v1/guardians/me/invitations');
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  /// POST /api/v1/guardians/me/invitations/{invitationId}/accept
  Future<void> acceptInvitation(int invitationId) async {
    await _dio.post(
        '/api/v1/guardians/me/invitations/$invitationId/accept');
  }

  /// POST /api/v1/guardians/me/invitations/{invitationId}/reject
  Future<void> rejectInvitation(int invitationId) async {
    await _dio.post(
        '/api/v1/guardians/me/invitations/$invitationId/reject');
  }

  // ── Mapping helpers ─────────────────────────────────────────────────────

  Ward _cardToWard(Map<String, dynamic> card) {
    final statusStr = card['status'] as String? ?? 'NORMAL';
    final status = switch (statusStr) {
      'EMERGENCY' => WardStatus.emergency,
      'WARNING' => WardStatus.warning,
      'AWAY' => WardStatus.outing,
      'OFFLINE' => WardStatus.offline,
      _ => WardStatus.normal,
    };

    final latestEvent = card['latestEvent'] as Map<String, dynamic>?;
    final lastUpdated = latestEvent != null
        ? (_parseDate(latestEvent['createdAt']) ?? DateTime.now())
        : DateTime.now();

    return Ward(
      id: card['userId'].toString(),
      name: card['name'] as String? ?? '',
      phoneNumber: '',
      relationship: card['relation'] as String? ?? '',
      status: status,
      lastUpdated: lastUpdated,
    );
  }

  BiometricData _cardToBiometric(Map<String, dynamic> card, String wardId) {
    final hr = (card['heartRate'] as num?)?.toInt() ?? 0;
    final br = (card['breathRate'] as num?)?.toInt() ?? 0;
    final statusStr = card['status'] as String? ?? 'NORMAL';
    return BiometricData(
      wardId: wardId,
      heartRate: hr,
      respiratoryRate: br,
      isActive: statusStr != 'OFFLINE',
      recordedAt: DateTime.now(),
    );
  }

  EmergencyAlert _alertToEntity(Map<String, dynamic> alert) {
    final eventType = alert['eventType'] as String? ?? 'FALL';
    final type = switch (eventType) {
      'FALL' => AlertType.fall,
      'HEART_ISSUE' => AlertType.heartRateAbnormal,
      'BREATH_ISSUE' => AlertType.heartRateAbnormal,
      'SOS' => AlertType.sos,
      _ => AlertType.fall,
    };
    final isResolved = (alert['status'] as String?) == 'RESOLVED';

    return EmergencyAlert(
      id: alert['id'].toString(),
      wardId: alert['id'].toString(),
      wardName: alert['userName'] as String? ?? '',
      type: type,
      message: alert['detail'] as String? ?? type.description,
      occurredAt: _parseDate(alert['createdAt']) ?? DateTime.now(),
      isResolved: isResolved,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is List && value.length >= 3) {
      return DateTime(
        value[0] as int, value[1] as int, value[2] as int,
        value.length > 3 ? value[3] as int : 0,
        value.length > 4 ? value[4] as int : 0,
      );
    }
    return null;
  }
}
