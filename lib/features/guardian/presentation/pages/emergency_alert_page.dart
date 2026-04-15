import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/emergency_alert.dart';

class EmergencyAlertPage extends StatelessWidget {
  const EmergencyAlertPage({super.key, required this.alert});

  final EmergencyAlert alert;

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}초 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    return '${diff.inHours}시간 전';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('긴급 알림')),
      body: ListView(
        children: [
          ListTile(title: const Text('피보호자'), trailing: Text(alert.wardName)),
          ListTile(title: const Text('알림 유형'), trailing: Text(alert.type.label)),
          ListTile(title: const Text('상세 내용'), subtitle: Text(alert.type.description)),
          ListTile(
            title: const Text('발생 시각'),
            trailing: Text(_timeAgo(alert.occurredAt)),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => _call('119'),
                  child: const Text('119 응급 신고'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _call('010-0000-0000'),
                  child: Text('${alert.wardName}에게 전화'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
