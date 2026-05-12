import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/status_dot.dart';
import '../../data/models/ward_detail_model.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';
import 'biometric_history_page.dart';
import 'emergency_alert_page.dart';

class WardDetailPage extends ConsumerWidget {
  const WardDetailPage({super.key, required this.ward});

  final Ward ward;

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('피보호자 삭제'),
        content: Text('${ward.name}님을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(wardsProvider.notifier).removeWard(ward.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

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

  Color _statusColor(WardStatus s) => switch (s) {
        WardStatus.normal => AppColors.statusNormal,
        WardStatus.warning => AppColors.statusWarning,
        WardStatus.emergency => AppColors.statusDanger,
        WardStatus.offline => AppColors.statusOffline,
        WardStatus.outing => AppColors.statusOuting,
      };

  String _statusLabel(WardStatus s) => switch (s) {
        WardStatus.normal => '정상',
        WardStatus.warning => '주의',
        WardStatus.emergency => '긴급',
        WardStatus.offline => '오프라인',
        WardStatus.outing => '외출 중',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardDetailAsync =
        ref.watch(wardDetailProvider(int.tryParse(ward.id) ?? 0));
    // fallback to snapshot biometric from ward list if detail not yet loaded
    final snapshotBiometric = ref.watch(biometricProvider(ward.id));
    final alerts = ref.watch(alertsByWardProvider(ward.id));
    final isOuting = ward.status == WardStatus.outing;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          ward.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wardDetailProvider(int.tryParse(ward.id) ?? 0));
          ref.read(wardsProvider.notifier).reload();
        },
        color: AppColors.primary,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 카드
          _Card(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ward.status == WardStatus.emergency
                        ? AppColors.dangerSurface
                        : AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ward.name[0],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ward.status == WardStatus.emergency
                            ? AppColors.danger
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ward.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ward.relationship}${ward.age != null ? ' · ${ward.age}세' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusDot(
                  status: switch (ward.status) {
                    WardStatus.normal => StatusLevel.normal,
                    WardStatus.warning => StatusLevel.warning,
                    WardStatus.emergency => StatusLevel.danger,
                    WardStatus.offline => StatusLevel.offline,
                    WardStatus.outing => StatusLevel.normal,
                  },
                  size: 12,
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(ward.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(ward.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(ward.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 오늘의 활동
          if (ward.sleepTime != null || ward.activityTime != null || ward.outingTime != null) ...[
            const _SectionHeader(title: '오늘의 활동'),
            const SizedBox(height: 8),
            _Card(
              child: Row(
                children: [
                  if (ward.sleepTime != null)
                    Expanded(
                      child: _ActivityItem(
                        icon: Icons.nightlight_round,
                        label: '수면',
                        value: ward.sleepTime!,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  if (ward.sleepTime != null && ward.activityTime != null)
                    Container(width: 1, height: 40, color: AppColors.border),
                  if (ward.activityTime != null)
                    Expanded(
                      child: _ActivityItem(
                        icon: Icons.directions_walk,
                        label: '활동',
                        value: ward.activityTime!,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  if (ward.activityTime != null && ward.outingTime != null)
                    Container(width: 1, height: 40, color: AppColors.border),
                  if (ward.outingTime != null)
                    Expanded(
                      child: _ActivityItem(
                        icon: Icons.exit_to_app,
                        label: '외출',
                        value: ward.outingTime!,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 실시간 생체 데이터
          _SectionHeader(
            title: '실시간 생체 데이터',
            action: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BiometricHistoryPage(
                    wardId: ward.id,
                    wardName: ward.name,
                  ),
                ),
              ),
              child: const Text('이력 보기',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 8),
          if (isOuting)
            _Card(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_walk, size: 16, color: AppColors.outing),
                      SizedBox(width: 8),
                      Text(
                        '외출 중 — 데이터 수신 불가',
                        style: TextStyle(color: AppColors.outing),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            wardDetailAsync.when(
              loading: () => _Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BiometricItem(
                      icon: Icons.favorite_rounded,
                      label: '심박수',
                      value: snapshotBiometric != null && snapshotBiometric.isActive
                          ? '${snapshotBiometric.heartRate}'
                          : '-',
                      unit: 'bpm',
                      wardStatus: ward.status,
                    ),
                    _Divider(),
                    _BiometricItem(
                      icon: Icons.air_rounded,
                      label: '호흡수',
                      value: snapshotBiometric != null && snapshotBiometric.isActive
                          ? '${snapshotBiometric.respiratoryRate}'
                          : '-',
                      unit: '/min',
                      wardStatus: ward.status,
                    ),
                  ],
                ),
              ),
              error: (_, __) => _Card(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('데이터 없음 (오프라인)',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              data: (detail) => Column(
                children: [
                  _Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BiometricItem(
                          icon: Icons.favorite_rounded,
                          label: '심박수',
                          value: '${detail.heartRate}',
                          unit: 'bpm',
                          wardStatus: ward.status,
                        ),
                        _Divider(),
                        _BiometricItem(
                          icon: Icons.air_rounded,
                          label: '호흡수',
                          value: '${detail.breathRate}',
                          unit: '/min',
                          wardStatus: ward.status,
                        ),
                        _Divider(),
                        _BiometricItem(
                          icon: detail.activityStatus
                              ? Icons.directions_walk
                              : Icons.bedtime_outlined,
                          label: '활동상태',
                          value: detail.activityStatus ? '활동 중' : '비활동',
                          unit: '',
                          wardStatus: ward.status,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // 미해결 알림
          const _SectionHeader(title: '미해결 알림'),
          const SizedBox(height: 8),
          if (alerts.isEmpty)
            _Card(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.statusNormal, size: 18),
                    SizedBox(width: 8),
                    Text('미해결 알림 없음',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...alerts.map((a) {
              final alertColor = _alertColor(a.type);
              final alertSurface = _alertSurface(a.type);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: alertSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: alertColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(_alertIcon(a.type), color: alertColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.type.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: alertColor,
                            ),
                          ),
                          Text(
                            a.message,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EmergencyAlertPage(alert: a),
                        ),
                      ),
                      child: Text('보기',
                          style: TextStyle(color: alertColor)),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(alertsProvider.notifier).resolve(a.id),
                      child: const Text('해결',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 12),

          // 연락처 정보
          const _SectionHeader(title: '연락처'),
          const SizedBox(height: 8),
          _Card(
            child: Row(
              children: [
                const Icon(Icons.phone_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  ward.phoneNumber,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 액션 버튼
          ElevatedButton.icon(
            onPressed: () => _call(ward.phoneNumber),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.phone),
            label: Text('${ward.name}님에게 전화'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _call('119'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.local_hospital),
            label: const Text('119 응급 신고'),
          ),

          const SizedBox(height: 40),
        ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _BiometricItem extends StatelessWidget {
  const _BiometricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.wardStatus,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final WardStatus wardStatus;

  Color get _color => switch (wardStatus) {
        WardStatus.emergency => AppColors.danger,
        WardStatus.warning => AppColors.warning,
        WardStatus.normal => AppColors.statusNormal,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 48, color: AppColors.border);
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}
