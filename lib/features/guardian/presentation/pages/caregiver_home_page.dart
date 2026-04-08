import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';
import 'ward_detail_page.dart';
import 'emergency_alert_page.dart';

class CaregiverHomePage extends ConsumerWidget {
  const CaregiverHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wards = ref.watch(wardsProvider);
    final alerts = ref.watch(activeAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 홈'),
        actions: [
          if (alerts.isNotEmpty)
            Badge(
              label: Text('${alerts.length}'),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EmergencyAlertPage(alert: alerts.first),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '모니터링 중: ${wards.length}명 | 긴급 알림: ${alerts.length}건',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const Divider(height: 1),

          // 피보호자 목록
          Expanded(
            child: ListView.separated(
              itemCount: wards.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final ward = wards[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(ward.name[0])),
                  title: Text('${ward.name} (${ward.age}세)'),
                  subtitle: Text(_statusLabel(ward.status)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WardDetailPage(ward: ward),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }

  String _statusLabel(WardStatus s) => switch (s) {
        WardStatus.normal => '정상',
        WardStatus.warning => '주의',
        WardStatus.emergency => '긴급',
        WardStatus.offline => '오프라인',
      };
}
