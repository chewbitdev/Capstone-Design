import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../data/demo/guardian_demo_data.dart';
import '../../data/repositories/guardian_repository.dart';
import '../../data/models/ward_detail_model.dart';
import '../../data/models/notification_model.dart';

// ── Repository ─────────────────────────────────────────────────────────────

final guardianRepositoryProvider = Provider<GuardianRepository>(
  (_) => GuardianRepository(),
);

// ── Biometrics map (keyed by wardId) ──────────────────────────────────────

final biometricsMapProvider = StateProvider<Map<String, BiometricData>>(
  (_) => kGuardianDemoMode ? GuardianDemoData.biometrics : {},
);

// ── Wards StateNotifier ────────────────────────────────────────────────────

class WardsNotifier extends StateNotifier<List<Ward>> {
  final GuardianRepository _repo;
  final Ref _ref;

  WardsNotifier(this._repo, this._ref)
      : super(kGuardianDemoMode ? GuardianDemoData.wards : []) {
    if (!kGuardianDemoMode) _load(_repo, _ref);
  }

  Future<void> _load(GuardianRepository repo, Ref ref) async {
    try {
      final (wards, biometrics) = await repo.fetchUsersAndBiometrics();
      if (!mounted) return;
      state = wards;
      ref.read(biometricsMapProvider.notifier).state = biometrics;
    } catch (_) {}
  }

  void reload() {
    if (!kGuardianDemoMode) _load(_repo, _ref);
  }

  void addWard(Ward ward) => state = [...state, ward];

  void updateWard(Ward updated) {
    state = [
      for (final w in state)
        if (w.id == updated.id) updated else w,
    ];
  }

  void removeWard(String id) =>
      state = state.where((w) => w.id != id).toList();
}

// ── Alerts StateNotifier ───────────────────────────────────────────────────

class AlertsNotifier extends StateNotifier<List<EmergencyAlert>> {
  final GuardianRepository _repo;

  AlertsNotifier(this._repo)
      : super(kGuardianDemoMode ? GuardianDemoData.alerts : []) {
    if (!kGuardianDemoMode) _load();
  }

  Future<void> _load() async {
    try {
      final alerts = await _repo.fetchAlerts();
      if (mounted) state = alerts;
    } catch (_) {}
  }

  void reload() {
    if (!kGuardianDemoMode) _load();
  }

  void resolve(String alertId) {
    if (!kGuardianDemoMode) {
      final id = int.tryParse(alertId);
      if (id != null) _repo.resolveEvent(id).catchError((_) {});
    }
    state = [
      for (final a in state)
        if (a.id == alertId)
          EmergencyAlert(
            id: a.id,
            wardId: a.wardId,
            wardName: a.wardName,
            type: a.type,
            message: a.message,
            occurredAt: a.occurredAt,
            isResolved: true,
          )
        else
          a,
    ];
  }

  void resolveWithMessage(String alertId, String newMessage) {
    if (!kGuardianDemoMode) {
      final id = int.tryParse(alertId);
      if (id != null) _repo.resolveEvent(id).catchError((_) {});
    }
    state = [
      for (final a in state)
        if (a.id == alertId)
          EmergencyAlert(
            id: a.id,
            wardId: a.wardId,
            wardName: a.wardName,
            type: a.type,
            message: newMessage,
            occurredAt: a.occurredAt,
            isResolved: true,
          )
        else
          a,
    ];
  }

  void dismiss(String alertId) {
    state = state.where((a) => a.id != alertId).toList();
  }

  void resolveAll() {
    if (!kGuardianDemoMode) {
      _repo.resolveAllEvents().catchError((_) {});
    }
    state = [
      for (final a in state)
        EmergencyAlert(
          id: a.id,
          wardId: a.wardId,
          wardName: a.wardName,
          type: a.type,
          message: a.message,
          occurredAt: a.occurredAt,
          isResolved: true,
        ),
    ];
  }
}

// ── Providers ──────────────────────────────────────────────────────────────

final wardsProvider =
    StateNotifierProvider<WardsNotifier, List<Ward>>(
  (ref) => WardsNotifier(ref.watch(guardianRepositoryProvider), ref),
);

final biometricProvider = Provider.family<BiometricData?, String>(
  (ref, wardId) => kGuardianDemoMode
      ? GuardianDemoData.biometrics[wardId]
      : ref.watch(biometricsMapProvider)[wardId],
);

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, List<EmergencyAlert>>(
  (ref) => AlertsNotifier(ref.watch(guardianRepositoryProvider)),
);

final activeAlertsProvider = Provider<List<EmergencyAlert>>(
  (ref) => ref.watch(alertsProvider).where((a) => !a.isResolved).toList(),
);

final alertsByWardProvider = Provider.family<List<EmergencyAlert>, String>(
  (ref, wardId) => ref
      .watch(alertsProvider)
      .where((a) => a.wardId == wardId && !a.isResolved)
      .toList(),
);

final allAlertsByWardProvider = Provider.family<List<EmergencyAlert>, String>(
  (ref, wardId) => ref
      .watch(alertsProvider)
      .where((a) => a.wardId == wardId)
      .toList()
    ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
);

// ── 피보호자 상세 생체데이터 (WardDetailPage 용) ─────────────────────────────

final wardDetailProvider =
    FutureProvider.family<WardDetailModel, int>((ref, userId) async {
  return ref.watch(guardianRepositoryProvider).getUserStateDetail(userId);
});

// ── 알림 목록 ──────────────────────────────────────────────────────────────

final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  return ref.watch(guardianRepositoryProvider).getNotifications();
});

// ── 읽지 않은 알림 수 (뱃지용) ───────────────────────────────────────────────

final unreadCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(guardianRepositoryProvider).getUnreadCount();
});

// ── 대기 중인 초대 ──────────────────────────────────────────────────────────

class PendingInvitation {
  const PendingInvitation({
    required this.invitationId,
    required this.wardName,
    required this.relation,
    required this.isPrimary,
    required this.createdAt,
  });

  final int invitationId;
  final String wardName;
  final String relation;
  final bool isPrimary;
  final DateTime createdAt;

  factory PendingInvitation.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is List && v.length >= 3) {
        return DateTime(v[0] as int, v[1] as int, v[2] as int,
            v.length > 3 ? v[3] as int : 0, v.length > 4 ? v[4] as int : 0);
      }
      return DateTime.now();
    }

    return PendingInvitation(
      invitationId: json['invitationId'] as int,
      wardName: json['wardName'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class InvitationsNotifier extends StateNotifier<List<PendingInvitation>> {
  final GuardianRepository _repo;
  final Ref _ref;

  InvitationsNotifier(this._repo, this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await _repo.getPendingInvitations();
      if (mounted) {
        state = raw.map(PendingInvitation.fromJson).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[InvitationsNotifier] load error: $e');
    }
  }

  Future<void> accept(int invitationId) async {
    await _repo.acceptInvitation(invitationId);
    if (!mounted) return;
    state = state.where((i) => i.invitationId != invitationId).toList();
    // 수락 후 피보호자 목록 즉시 새로고침
    _ref.read(wardsProvider.notifier).reload();
  }

  Future<void> reject(int invitationId) async {
    await _repo.rejectInvitation(invitationId);
    if (mounted) {
      state = state.where((i) => i.invitationId != invitationId).toList();
    }
  }
}

final pendingInvitationsProvider =
    StateNotifierProvider<InvitationsNotifier, List<PendingInvitation>>(
  (ref) => InvitationsNotifier(ref.watch(guardianRepositoryProvider), ref),
);
