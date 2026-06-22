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

enum AlertType {
  fall,
  heartRateAbnormal,
  breathRateAbnormal,
  vitalIssue,
  manualAlert,
  inactivity,
  outing,
  invitation,
}

extension AlertTypeLabel on AlertType {
  String get label => switch (this) {
        AlertType.fall => '낙상 감지',
        AlertType.heartRateAbnormal => '심박수 이상',
        AlertType.breathRateAbnormal => '호흡수 이상',
        AlertType.vitalIssue => '심박·호흡 동시 이상',
        AlertType.manualAlert => '도움 요청',
        AlertType.inactivity => '장시간 미활동',
        AlertType.outing => '외출 감지',
        AlertType.invitation => '보호자 초대',
      };

  String get description => switch (this) {
        AlertType.fall => '낙상이 감지되었습니다. 즉시 확인이 필요합니다.',
        AlertType.heartRateAbnormal => '심박수가 정상 범위를 벗어났습니다.',
        AlertType.breathRateAbnormal => '호흡수가 정상 범위를 벗어났습니다.',
        AlertType.vitalIssue => '심박수와 호흡수에 동시에 이상이 감지되었습니다. 즉시 확인이 필요합니다.',
        AlertType.manualAlert => '피보호자가 도움을 요청했습니다.',
        AlertType.inactivity => '30분 이상 움직임이 감지되지 않습니다.',
        AlertType.outing => '피보호자가 외출 중입니다.',
        AlertType.invitation => '보호자로 초대되었습니다.',
      };
}
