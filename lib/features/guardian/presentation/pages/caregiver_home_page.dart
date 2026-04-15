import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';
import 'add_ward_page.dart';
import 'alert_history_page.dart';
import 'ward_detail_page.dart';

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
          Badge(
            label: Text('${alerts.length}'),
            isLabelVisible: alerts.isNotEmpty,
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlertHistoryPage()),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '모니터링 중: ${wards.length}명 | 긴급 알림: ${alerts.length}건',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: wards.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final ward = wards[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(ward.name[0])),
                  title: Text(ward.name),
                  subtitle: Text('${_statusLabel(ward.status)} · ${ward.relationship}'),
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddWardPage()),
        ),
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
