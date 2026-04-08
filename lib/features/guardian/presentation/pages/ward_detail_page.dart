import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';
import 'emergency_alert_page.dart';

class WardDetailPage extends ConsumerWidget {
  const WardDetailPage({super.key, required this.ward});

  final Ward ward;

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(biometricProvider(ward.id));
    final alerts = ref.watch(alertsByWardProvider(ward.id));

    return Scaffold(
      appBar: AppBar(title: Text(ward.name)),
      body: ListView(
        children: [
          // 기본 정보
          const _SectionHeader('기본 정보'),
          ListTile(title: const Text('이름'), trailing: Text(ward.name)),
          ListTile(title: const Text('나이'), trailing: Text('${ward.age}세')),
          ListTile(title: const Text('전화번호'), trailing: Text(ward.phoneNumber)),
          ListTile(
            title: const Text('상태'),
            trailing: Text(_statusLabel(ward.status)),
          ),

          const Divider(),

          // 생체 데이터
          const _SectionHeader('실시간 생체 데이터'),
          if (biometric == null || !biometric.isActive)
            const ListTile(title: Text('데이터 없음 (오프라인)'))
          else ...[
            ListTile(
              title: const Text('심박수'),
              trailing: Text('${biometric.heartRate} bpm'
                  '${biometric.isHeartRateAbnormal ? ' ⚠️' : ''}'),
            ),
            ListTile(
              title: const Text('호흡수'),
              trailing: Text('${biometric.respiratoryRate} 회/분'
                  '${biometric.isRespiratoryAbnormal ? ' ⚠️' : ''}'),
            ),
            ListTile(
              title: const Text('산소포화도'),
              trailing: Text('${biometric.spO2.toStringAsFixed(1)} %'
                  '${biometric.isSpO2Abnormal ? ' ⚠️' : ''}'),
            ),
            ListTile(
              title: const Text('활동 상태'),
              trailing: Text(biometric.isActive ? '활동 중' : '비활동'),
            ),
          ],

          const Divider(),

          // 긴급 알림
          const _SectionHeader('미해결 긴급 알림'),
          if (alerts.isEmpty)
            const ListTile(title: Text('없음'))
          else
            ...alerts.map(
              (a) => ListTile(
                leading: const Icon(Icons.warning),
                title: Text(a.type.label),
                subtitle: Text(a.message),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmergencyAlertPage(alert: a),
                    ),
                  ),
                  child: const Text('보기'),
                ),
              ),
            ),

          const Divider(),

          // 액션 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => _call(ward.phoneNumber),
                  child: Text('${ward.name}에게 전화'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _call('119'),
                  child: const Text('119 신고'),
                ),
              ],
            ),
          ),
        ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
