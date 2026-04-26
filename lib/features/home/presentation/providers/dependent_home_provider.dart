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
