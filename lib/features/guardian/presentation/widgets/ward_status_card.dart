import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/status_dot.dart';
import '../../domain/entities/ward.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/emergency_alert.dart';
import '../providers/guardian_provider.dart';

class WardStatusCard extends ConsumerWidget {
  const WardStatusCard({
    super.key,
    required this.ward,
    required this.onTap,
  });

  final Ward ward;
  final VoidCallback onTap;

  StatusLevel _statusLevel(WardStatus s) => switch (s) {
        WardStatus.normal => StatusLevel.normal,
        WardStatus.warning => StatusLevel.warning,
        WardStatus.emergency => StatusLevel.danger,
        WardStatus.offline => StatusLevel.offline,
      };

  String _statusLabel(WardStatus s) => switch (s) {
        WardStatus.normal => '정상',
        WardStatus.warning => '주의',
        WardStatus.emergency => '긴급',
        WardStatus.offline => '오프라인',
      };

  Color _statusColor(WardStatus s) => switch (s) {
        WardStatus.normal => AppColors.statusNormal,
        WardStatus.warning => AppColors.statusWarning,
        WardStatus.emergency => AppColors.statusDanger,
        WardStatus.offline => AppColors.statusOffline,
      };

  String _lastUpdatedText(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometric = ref.watch(biometricProvider(ward.id));
    final alerts = ref.watch(alertsByWardProvider(ward.id));
    final isEmergency = ward.status == WardStatus.emergency;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEmergency ? AppColors.danger : AppColors.border,
            width: isEmergency ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isEmergency
                  ? AppColors.danger.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Emergency banner
            if (isEmergency)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      alerts.isNotEmpty
                          ? alerts.first.type.label
                          : '긴급 상황 발생',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  _Avatar(name: ward.name, status: ward.status),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              ward.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${ward.age}세',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (biometric != null && biometric.isActive)
                          _BiometricRow(biometric: biometric)
                        else
                          const Text(
                            '데이터 없음',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          _lastUpdatedText(ward.lastUpdated),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusDot(status: _statusLevel(ward.status), size: 10),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor(ward.status)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(ward.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(ward.status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppColors.textHint),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.status});

  final String name;
  final WardStatus status;

  @override
  Widget build(BuildContext context) {
    final isEmergency = status == WardStatus.emergency;
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isEmergency
                ? AppColors.dangerSurface
                : AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isEmergency ? AppColors.danger : AppColors.primary,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: StatusDot(
            status: switch (status) {
              WardStatus.normal => StatusLevel.normal,
              WardStatus.warning => StatusLevel.warning,
              WardStatus.emergency => StatusLevel.danger,
              WardStatus.offline => StatusLevel.offline,
            },
            size: 14,
          ),
        ),
      ],
    );
  }
}

class _BiometricRow extends StatelessWidget {
  const _BiometricRow({required this.biometric});

  final BiometricData biometric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Metric(
          icon: Icons.favorite,
          value: '${biometric.heartRate}',
          unit: 'bpm',
          isAbnormal: biometric.isHeartRateAbnormal,
        ),
        const SizedBox(width: 12),
        _Metric(
          icon: Icons.air,
          value: '${biometric.respiratoryRate}',
          unit: '/min',
          isAbnormal: biometric.isRespiratoryAbnormal,
        ),
        const SizedBox(width: 12),
        _Metric(
          icon: Icons.water_drop,
          value: biometric.spO2.toStringAsFixed(1),
          unit: '%',
          isAbnormal: biometric.isSpO2Abnormal,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.unit,
    required this.isAbnormal,
  });

  final IconData icon;
  final String value;
  final String unit;
  final bool isAbnormal;

  @override
  Widget build(BuildContext context) {
    final color = isAbnormal ? AppColors.danger : AppColors.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isAbnormal ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
