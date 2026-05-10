import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

enum _AlertLevel { danger, warning, info }

class _NotificationItem {
  final String title;
  final String body;
  final String time;
  final _AlertLevel level;
  final bool isRead;

  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.level,
    this.isRead = false,
  });
}

const _dummyNotifications = [
  _NotificationItem(
    title: '심박수 이상 감지',
    body: '심박수가 120bpm을 초과했습니다. 현재 측정값: 127bpm\n보호자에게 자동으로 알림을 전송했습니다.',
    time: '방금 전',
    level: _AlertLevel.danger,
  ),
  _NotificationItem(
    title: '호흡수 이상 감지',
    body: '호흡수가 정상 범위를 벗어났습니다. 현재 측정값: 24회/분\n보호자에게 자동으로 알림을 전송했습니다.',
    time: '12분 전',
    level: _AlertLevel.warning,
  ),
  _NotificationItem(
    title: '낙상 감지',
    body: '낙상이 감지되었습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
    time: '1시간 전',
    level: _AlertLevel.danger,
    isRead: true,
  ),
  _NotificationItem(
    title: '심박수 이상 감지',
    body: '심박수가 40bpm 미만으로 떨어졌습니다. 현재 측정값: 38bpm\n보호자에게 자동으로 알림을 전송했습니다.',
    time: '3시간 전',
    level: _AlertLevel.danger,
    isRead: true,
  ),
  _NotificationItem(
    title: '장시간 무활동 감지',
    body: '2시간 이상 움직임이 감지되지 않았습니다.\n보호자에게 자동으로 알림을 전송했습니다.',
    time: '어제 오후 3:20',
    level: _AlertLevel.warning,
    isRead: true,
  ),
  _NotificationItem(
    title: '센서 연결 끊김',
    body: '라즈베리파이와 연결이 끊겼습니다. 기기 상태를 확인해주세요.',
    time: '어제 오전 11:05',
    level: _AlertLevel.info,
    isRead: true,
  ),
];

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = _dummyNotifications.where((n) => !n.isRead).toList();
    final read = _dummyNotifications.where((n) => n.isRead).toList();

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
      body: _dummyNotifications.isEmpty
          ? const Center(
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
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unread.isNotEmpty) ...[
                  _SectionLabel('읽지 않음 (${unread.length}건)'),
                  const SizedBox(height: 8),
                  ...unread.map((item) => _NotificationCard(item: item)),
                  const SizedBox(height: 16),
                ],
                if (read.isNotEmpty) ...[
                  _SectionLabel('읽음 (${read.length}건)'),
                  const SizedBox(height: 8),
                  ...read.map((item) => _NotificationCard(item: item)),
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

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final _NotificationItem item;

  Color get _color => switch (item.level) {
        _AlertLevel.danger => AppColors.danger,
        _AlertLevel.warning => AppColors.warning,
        _AlertLevel.info => AppColors.statusOffline,
      };

  Color get _surface => switch (item.level) {
        _AlertLevel.danger => AppColors.dangerSurface,
        _AlertLevel.warning => AppColors.warningSurface,
        _AlertLevel.info => const Color(0xFFF5F5F5),
      };

  IconData get _icon => switch (item.level) {
        _AlertLevel.danger => Icons.warning_rounded,
        _AlertLevel.warning => Icons.info_outline,
        _AlertLevel.info => Icons.sensors_off_outlined,
      };

  String get _levelLabel => switch (item.level) {
        _AlertLevel.danger => '심각',
        _AlertLevel.warning => '주의',
        _AlertLevel.info => '정보',
      };

  @override
  Widget build(BuildContext context) {
    final color = item.isRead ? AppColors.textHint : _color;
    final surface = item.isRead ? const Color(0xFFF5F5F5) : _surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead
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
            decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
            child: Icon(_icon, size: 18, color: color),
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
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                          color: item.isRead
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: item.isRead
                              ? TextDecoration.none
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _levelLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
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
