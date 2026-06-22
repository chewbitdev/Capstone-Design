import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/emergency_event_model.dart';
import '../../data/models/guardian_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/vital_model.dart';
import '../../data/repositories/dependent_repository.dart';
import '../../../../core/auth/auth_storage.dart';

final dependentRepositoryProvider = Provider<DependentRepository>(
  (_) => DependentRepository(),
);

final userIdProvider = FutureProvider<int?>((ref) async {
  return AuthStorage.getUserId();
});

final userProfileProvider = FutureProvider<UserProfileModel?>((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return null;
  return ref.watch(dependentRepositoryProvider).getUserProfile(userId);
});

final emergencyEventProvider = FutureProvider<EmergencyEventModel?>((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return null;
  return ref.watch(dependentRepositoryProvider).getEmergencyEvent(userId);
});

final guardiansProvider = FutureProvider<List<GuardianModel>>((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return [];
  return ref.watch(dependentRepositoryProvider).getGuardians(userId);
});

final vitalsStreamProvider = StreamProvider<VitalModel>((ref) async* {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return;
  yield* ref.watch(dependentRepositoryProvider).streamVitals(userId);
});

final deviceStatusProvider = FutureProvider((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return null;
  return ref.watch(dependentRepositoryProvider).getDeviceStatus(userId);
});

final eventHistoryProvider =
    FutureProvider<List<EmergencyEventModel>>((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  if (userId == null) return [];
  return ref.watch(dependentRepositoryProvider).getEventHistory(userId);
});

// 데모 모드 전용: 낙상 이벤트를 런타임에 추가하기 위한 StateNotifier
class _DemoEventHistoryNotifier extends StateNotifier<List<EmergencyEventModel>> {
  _DemoEventHistoryNotifier() : super([]);

  void addFallEvent() {
    state = [
      EmergencyEventModel(
        id: DateTime.now().millisecondsSinceEpoch,
        eventType: 'FALL',
        status: 'PENDING',
        createdAt: DateTime.now(),
      ),
      ...state,
    ];
  }
}

final demoEventHistoryProvider =
    StateNotifierProvider<_DemoEventHistoryNotifier, List<EmergencyEventModel>>(
  (_) => _DemoEventHistoryNotifier(),
);

Future<void> inviteGuardian({
  required int wardId,
  required String name,
  required String phone,
  required String relationship,
  required DependentRepository repo,
}) {
  return repo.inviteGuardian(
    wardId: wardId,
    name: name,
    phone: phone,
    relationship: relationship,
  );
}
