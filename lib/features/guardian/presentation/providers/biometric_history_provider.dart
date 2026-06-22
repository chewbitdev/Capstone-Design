import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vital_stats.dart';
import '../providers/guardian_provider.dart';

typedef VitalStatsKey = ({String wardId, String type, String period});

final vitalStatsProvider =
    FutureProvider.autoDispose.family<VitalStats, VitalStatsKey>(
  (ref, key) async {
    final repo = ref.watch(guardianRepositoryProvider);
    return repo.getVitalStats(int.parse(key.wardId), key.type, key.period);
  },
);
