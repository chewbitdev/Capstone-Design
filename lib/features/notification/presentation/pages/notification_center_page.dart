import 'package:flutter/material.dart';

enum _AlertLevel { warning, danger, info }

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

// 더미 데이터
const _dummyNotifications = [
  _NotificationItem(
    title: '심박수 이상 감지',
    body: '심박수가 120bpm을 초과했습니다. 현재 측정값: 127bpm',
    time: '방금 전',
    level: _AlertLevel.danger,
  ),
  _NotificationItem(
    title: '호흡수 이상 감지',
    body: '호흡수가 정상 범위를 벗어났습니다. 현재 측정값: 24/min',
    time: '12분 전',
    level: _AlertLevel.warning,
  ),
  _NotificationItem(
    title: '낙상 감지',
    body: '낙상이 감지되었습니다. 보호자에게 자동 알림이 전송되었습니다.',
    time: '1시간 전',
    level: _AlertLevel.danger,
    isRead: true,
  ),
  _NotificationItem(
    title: '심박수 이상 감지',
    body: '심박수가 40bpm 미만으로 떨어졌습니다. 현재 측정값: 38bpm',
    time: '3시간 전',
    level: _AlertLevel.danger,
    isRead: true,
  ),
  _NotificationItem(
    title: '장시간 무활동 감지',
    body: '2시간 이상 움직임이 감지되지 않았습니다.',
    time: '어제 오후 3:20',
    level: _AlertLevel.warning,
    isRead: true,
  ),
  _NotificationItem(
    title: '웨어러블 연결 끊김',
    body: '기기 연결이 끊겼습니다. 기기 상태를 확인해주세요.',
    time: '어제 오전 11:05',
    level: _AlertLevel.info,
    isRead: true,
  ),
];

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount = _dummyNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (unreadCount > 0)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                '읽지 않은 알림 $unreadCount건',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          Expanded(
            child: _dummyNotifications.isEmpty
                ? const Center(
                    child: Text(
                      '알림이 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _dummyNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 1),
                    itemBuilder: (context, index) {
                      final item = _dummyNotifications[index];
                      return _NotificationCard(item: item);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;
  const _NotificationCard({required this.item});

  Color get _levelColor {
    switch (item.level) {
      case _AlertLevel.danger:
        return const Color(0xFFD32F2F);
      case _AlertLevel.warning:
        return const Color(0xFF757575);
      case _AlertLevel.info:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get _levelIcon {
    switch (item.level) {
      case _AlertLevel.danger:
        return Icons.error_outline;
      case _AlertLevel.warning:
        return Icons.warning_amber_outlined;
      case _AlertLevel.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.isRead ? const Color(0xFFF5F5F5) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_levelIcon, size: 20, color: _levelColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
