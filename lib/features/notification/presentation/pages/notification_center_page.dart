import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../home/data/demo/dependent_demo_data.dart';
import '../../../home/data/models/emergency_event_model.dart';
import '../../../home/presentation/providers/dependent_home_provider.dart';

enum _AlertLevel { danger, warning, info }

class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 데모 모드: demoEventHistoryProvider, 실제 모드: eventHistoryProvider
    final demoEvents = kDemoMode ? ref.watch(demoEventHistoryProvider) : null;
    final historyAsync = kDemoMode
        ? AsyncValue.data(demoEvents!)
        : ref.watch(eventHistoryProvider);

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
          '알림',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('알림을 불러올 수 없습니다.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 48, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('알림이 없습니다.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final unread = events.where((e) => e.status == 'PENDING').toList();
          final read = events.where((e) => e.status != 'PENDING').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unread.isNotEmpty) ...[
                _SectionLabel('읽지 않음 (${unread.length}건)'),
                const SizedBox(height: 8),
                ...unread.map((e) => _NotificationCard(event: e, isRead: false)),
                const SizedBox(height: 16),
              ],
              if (read.isNotEmpty) ...[
                _SectionLabel('읽음 (${read.length}건)'),
                const SizedBox(height: 8),
                ...read.map((e) => _NotificationCard(event: e, isRead: true)),
              ],
            ],
          );
        },
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

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.event, required this.isRead});

  final EmergencyEventModel event;
  final bool isRead;

  String get _title => switch (event.eventType) {
        'FALL' => '낙상 감지',
        'HEART_ISSUE' => '심박수 이상 감지',
        'BREATH_ISSUE' => '호흡수 이상 감지',
        'VITAL_ISSUE' => '심박수·호흡수 동시 이상',
        'MANUAL_ALERT' => '도움 요청 전송됨',
        _ => '응급 알림',
      };

  String get _body => switch (event.eventType) {
        'FALL' => '낙상이 감지되었습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
        'HEART_ISSUE' => '심박수가 정상 범위를 벗어났습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
        'BREATH_ISSUE' => '호흡수가 정상 범위를 벗어났습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
        'VITAL_ISSUE' => '심박수와 호흡수에 동시에 이상이 감지되었습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
        'MANUAL_ALERT' => '도움 요청 버튼이 눌렸습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
        _ => '응급 상황이 감지되었습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
      };

  _AlertLevel get _level => switch (event.eventType) {
        'FALL' => _AlertLevel.danger,
        'VITAL_ISSUE' => _AlertLevel.danger,
        'MANUAL_ALERT' => _AlertLevel.danger,
        'HEART_ISSUE' => _AlertLevel.warning,
        'BREATH_ISSUE' => _AlertLevel.warning,
        _ => _AlertLevel.info,
      };

  String get _levelLabel => switch (_level) {
        _AlertLevel.danger => '심각',
        _AlertLevel.warning => '주의',
        _AlertLevel.info => '정보',
      };

  Color get _color => switch (_level) {
        _AlertLevel.danger => AppColors.danger,
        _AlertLevel.warning => AppColors.warning,
        _AlertLevel.info => AppColors.statusOffline,
      };

  Color get _surface => switch (_level) {
        _AlertLevel.danger => AppColors.dangerSurface,
        _AlertLevel.warning => AppColors.warningSurface,
        _AlertLevel.info => const Color(0xFFF5F5F5),
      };

  IconData get _icon => switch (event.eventType) {
        'FALL' => Icons.warning_rounded,
        'VITAL_ISSUE' => Icons.warning_rounded,
        'MANUAL_ALERT' => Icons.pan_tool_rounded,
        'HEART_ISSUE' => Icons.favorite_border,
        'BREATH_ISSUE' => Icons.air,
        _ => Icons.sensors_off_outlined,
      };

  String _timeAgo() {
    final diff = DateTime.now().difference(event.createdAt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    final displayColor = isRead ? AppColors.textHint : _color;
    final displaySurface = isRead ? const Color(0xFFF5F5F5) : _surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead
              ? AppColors.border
              : _color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: displaySurface, shape: BoxShape.circle),
            child: Icon(_icon, size: 18, color: displayColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.w600,
                          color: isRead
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: displayColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _levelLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: displayColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _body,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
