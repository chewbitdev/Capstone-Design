import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../data/demo/guardian_demo_data.dart';
import '../../data/repositories/guardian_repository.dart';

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
  WardsNotifier(GuardianRepository repo, Ref ref)
      : super(kGuardianDemoMode ? GuardianDemoData.wards : []) {
    if (!kGuardianDemoMode) _load(repo, ref);
  }

  Future<void> _load(GuardianRepository repo, Ref ref) async {
    try {
      final (wards, biometrics) = await repo.fetchUsersAndBiometrics();
      if (!mounted) return;
      state = wards;
      ref.read(biometricsMapProvider.notifier).state = biometrics;
    } catch (_) {}
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
