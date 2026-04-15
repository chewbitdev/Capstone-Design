class EmergencyAlert {
  const EmergencyAlert({
    required this.id,
    required this.wardId,
    required this.wardName,
    required this.type,
    required this.message,
    required this.occurredAt,
    this.isResolved = false,
  });

  final String id;
  final String wardId;
  final String wardName;
  final AlertType type;
  final String message;
  final DateTime occurredAt;
  final bool isResolved;
}

enum AlertType { fall, heartRateAbnormal, spO2Low, inactivity, sos }

extension AlertTypeLabel on AlertType {
  String get label => switch (this) {
        AlertType.fall => '낙상 감지',
        AlertType.heartRateAbnormal => '심박수 이상',
        AlertType.spO2Low => '산소포화도 저하',
        AlertType.inactivity => '장시간 미활동',
        AlertType.sos => 'SOS 신호',
      };

  String get description => switch (this) {
        AlertType.fall => '낙상이 감지되었습니다. 즉시 확인이 필요합니다.',
        AlertType.heartRateAbnormal => '심박수가 정상 범위를 벗어났습니다.',
        AlertType.spO2Low => '산소포화도가 위험 수준으로 낮아졌습니다.',
        AlertType.inactivity => '30분 이상 움직임이 감지되지 않습니다.',
        AlertType.sos => '피보호자가 SOS 버튼을 눌렀습니다.',
      };
}
