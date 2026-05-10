import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../data/demo/guardian_demo_data.dart';

// ── Wards StateNotifier ────────────────────────────────────────────────────

class WardsNotifier extends StateNotifier<List<Ward>> {
  WardsNotifier()
      : super(kGuardianDemoMode ? GuardianDemoData.wards : []);

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
  AlertsNotifier()
      : super(kGuardianDemoMode ? GuardianDemoData.alerts : []);

  void resolve(String alertId) {
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
}

// ── Providers ──────────────────────────────────────────────────────────────

final wardsProvider =
    StateNotifierProvider<WardsNotifier, List<Ward>>((ref) => WardsNotifier());

final biometricProvider = Provider.family<BiometricData?, String>(
  (ref, wardId) => kGuardianDemoMode
      ? GuardianDemoData.biometrics[wardId]
      : null,
);

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, List<EmergencyAlert>>(
        (ref) => AlertsNotifier());

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
