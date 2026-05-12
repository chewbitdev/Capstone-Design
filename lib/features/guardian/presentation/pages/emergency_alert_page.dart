import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/models/event_detail_model.dart';
import '../../data/repositories/guardian_repository.dart';
import '../../domain/entities/emergency_alert.dart';
import '../providers/guardian_provider.dart';

final _eventDetailProvider =
    FutureProvider.family<EventDetailModel?, int>((ref, eventId) async {
  try {
    return await ref
        .watch(guardianRepositoryProvider)
        .getEmergencyEventDetail(eventId);
  } catch (_) {
    return null;
  }
});

class EmergencyAlertPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = int.tryParse(alert.id);
    final detailAsync =
        eventId != null ? ref.watch(_eventDetailProvider(eventId)) : null;

    final detail = detailAsync?.valueOrNull;

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
          '긴급 알림',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 긴급 배너
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AppColors.danger, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    alert.type.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    detail?.description ?? alert.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 상세 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow(
                      label: '피보호자',
                      value: detail?.name ?? alert.wardName),
                  const Divider(height: 20, color: AppColors.divider),
                  _InfoRow(label: '알림 유형', value: alert.type.label),
                  const Divider(height: 20, color: AppColors.divider),
                  _InfoRow(
                      label: '발생 시각',
                      value: _timeAgo(
                          detail?.occurredAt ?? alert.occurredAt)),
                  const Divider(height: 20, color: AppColors.divider),
                  _InfoRow(
                      label: '상세',
                      value: detail?.description ?? alert.type.description),
                ],
              ),
            ),

            const Spacer(),

            // 액션 버튼
            ElevatedButton.icon(
              onPressed: () => _call('119'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.local_hospital),
              label: const Text(
                '119 응급 신고',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () =>
                  _call('010-0000-0000'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.phone),
              label: Text(
                '${detail?.name ?? alert.wardName}님에게 전화',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
