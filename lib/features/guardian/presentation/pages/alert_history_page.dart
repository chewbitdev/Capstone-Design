import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/emergency_alert.dart';
import '../providers/guardian_provider.dart';
import 'emergency_alert_page.dart';

class AlertHistoryPage extends ConsumerWidget {
  const AlertHistoryPage({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(alertsProvider);

    final active = all.where((a) => !a.isResolved).toList();
    final resolved = all.where((a) => a.isResolved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 이력'),
        actions: [
          if (active.isNotEmpty)
            TextButton(
              onPressed: () {
                for (final a in active) {
                  ref.read(alertsProvider.notifier).resolve(a.id);
                }
              },
              child: const Text('전체 해결'),
            ),
        ],
      ),
      body: all.isEmpty
          ? const Center(child: Text('알림 이력이 없습니다'))
          : ListView(
              children: [
                if (active.isNotEmpty) ...[
                  const _SectionHeader('미해결'),
                  ...active.map((a) => _AlertTile(
                        alert: a,
                        timeAgo: _timeAgo(a.occurredAt),
                        onResolve: () =>
                            ref.read(alertsProvider.notifier).resolve(a.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EmergencyAlertPage(alert: a),
                          ),
                        ),
                      )),
                ],
                if (resolved.isNotEmpty) ...[
                  const _SectionHeader('해결됨'),
                  ...resolved.map((a) => _AlertTile(
                        alert: a,
                        timeAgo: _timeAgo(a.occurredAt),
                        isResolved: true,
                      )),
                ],
              ],
            ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
    required this.timeAgo,
    this.isResolved = false,
    this.onResolve,
    this.onTap,
  });

  final EmergencyAlert alert;
  final String timeAgo;
  final bool isResolved;
  final VoidCallback? onResolve;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.warning,
        color: isResolved ? Colors.grey : null,
      ),
      title: Text(
        '${alert.wardName} · ${alert.type.label}',
        style: TextStyle(
          color: isResolved ? Colors.grey : null,
          decoration: isResolved ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text('$timeAgo · ${alert.message}'),
      trailing: isResolved
          ? const Icon(Icons.check_circle_outline, color: Colors.grey, size: 20)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onTap != null)
                  TextButton(onPressed: onTap, child: const Text('보기')),
                if (onResolve != null)
                  TextButton(onPressed: onResolve, child: const Text('해결')),
              ],
            ),
      onTap: isResolved ? null : onTap,
    );
  }
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
