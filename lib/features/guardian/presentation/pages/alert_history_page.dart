import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '알림 이력',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (active.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(alertsProvider.notifier).resolveAll(),
              child: const Text('전체 해결',
                  style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: all.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 48, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('알림 이력이 없습니다.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (active.isNotEmpty) ...[
                  _SectionLabel('미해결 (${active.length}건)'),
                  const SizedBox(height: 8),
                  ...active.map(
                    (a) => a.type == AlertType.invitation
                        ? _InvitationCard(
                            alert: a,
                            timeAgo: _timeAgo(a.occurredAt),
                            onAccept: () => ref
                                .read(alertsProvider.notifier)
                                .resolveWithMessage(
                                    a.id,
                                    '${a.wardName}님의 초대를 수락했습니다.'),
                            onDecline: () => ref
                                .read(alertsProvider.notifier)
                                .dismiss(a.id),
                          )
                        : _AlertCard(
                            alert: a,
                            timeAgo: _timeAgo(a.occurredAt),
                            onResolve: () =>
                                ref.read(alertsProvider.notifier).resolve(a.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EmergencyAlertPage(alert: a),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (resolved.isNotEmpty) ...[
                  _SectionLabel('해결됨 (${resolved.length}건)'),
                  const SizedBox(height: 8),
                  ...resolved.map(
                    (a) => _AlertCard(
                      alert: a,
                      timeAgo: _timeAgo(a.occurredAt),
                      isResolved: true,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
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

  Color _alertColor(AlertType t) => switch (t) {
        AlertType.fall => AppColors.danger,
        AlertType.sos => AppColors.danger,
        AlertType.heartRateAbnormal => AppColors.warning,
        AlertType.inactivity => AppColors.statusOffline,
        AlertType.outing => AppColors.outing,
        AlertType.invitation => AppColors.primary,
      };

  Color _alertSurface(AlertType t) => switch (t) {
        AlertType.fall => AppColors.dangerSurface,
        AlertType.sos => AppColors.dangerSurface,
        AlertType.heartRateAbnormal => AppColors.warningSurface,
        AlertType.inactivity => const Color(0xFFF5F5F5),
        AlertType.outing => AppColors.outingSurface,
        AlertType.invitation => AppColors.primarySurface,
      };

  IconData _alertIcon(AlertType t) => switch (t) {
        AlertType.fall => Icons.warning_rounded,
        AlertType.sos => Icons.warning_rounded,
        AlertType.heartRateAbnormal => Icons.info_outline,
        AlertType.inactivity => Icons.info_outline,
        AlertType.outing => Icons.exit_to_app,
        AlertType.invitation => Icons.person_add_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final color = isResolved ? AppColors.textHint : _alertColor(alert.type);
    final surface =
        isResolved ? const Color(0xFFF5F5F5) : _alertSurface(alert.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isResolved ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isResolved
              ? AppColors.border
              : _alertColor(alert.type).withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: isResolved ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isResolved ? Icons.check_circle_outline : _alertIcon(alert.type),
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert.wardName} · ${alert.type.label}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isResolved ? FontWeight.normal : FontWeight.w600,
                        color: isResolved ? AppColors.textSecondary : AppColors.textPrimary,
                        decoration: isResolved ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$timeAgo · ${alert.message}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!isResolved) ...[
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4)),
                  child: Text('보기',
                      style: TextStyle(color: color, fontSize: 13)),
                ),
                TextButton(
                  onPressed: onResolve,
                  style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4)),
                  child: const Text('해결',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.alert,
    required this.timeAgo,
    required this.onAccept,
    required this.onDecline,
  });

  final EmergencyAlert alert;
  final String timeAgo;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${alert.wardName} · 보호자 초대',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$timeAgo · ${alert.message}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('거절', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('수락', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
