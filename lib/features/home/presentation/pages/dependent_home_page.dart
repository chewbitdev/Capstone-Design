import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../../../notification/presentation/pages/notification_center_page.dart';
import '../../../guardian/presentation/pages/guardian_register_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/auth/auth_storage.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/demo/dependent_demo_data.dart';
import '../providers/dependent_home_provider.dart';

class DependentHomePage extends ConsumerStatefulWidget {
  const DependentHomePage({super.key});

  @override
  ConsumerState<DependentHomePage> createState() => _DependentHomePageState();
}

class _DependentHomePageState extends ConsumerState<DependentHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _demoEmergency = false;
  bool _showNotification = false;
  Timer? _demoTimer;
  Timer? _vitalTimer;
  int _heartRate = 74;
  int _breathRate = 16;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.15, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (kDemoMode) {
      // 실시간 생체 데이터 변동 (1.5초마다)
      _vitalTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        if (!mounted) return;
        setState(() {
          if (_demoEmergency) {
            _heartRate = 125 + _random.nextInt(10);  // 125~134
            _breathRate = 24 + _random.nextInt(5);   // 24~28
          } else {
            _heartRate = 72 + _random.nextInt(6);    // 72~77
            _breathRate = 15 + _random.nextInt(3);   // 15~17
          }
        });
      });

      // 6초 후 응급 전환
      _demoTimer = Timer(const Duration(seconds: 6), () {
        if (!mounted) return;
        setState(() {
          _demoEmergency = true;
          _showNotification = true;
        });
        _pulseController.repeat(reverse: true);
        Timer(const Duration(seconds: 6), () {
          if (!mounted) return;
          setState(() => _showNotification = false);
        });
      });
    }
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _vitalTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _eventTypeLabel(String? type) => switch (type) {
        'FALL' => '낙상 감지',
        'HEART_ISSUE' => '심박 이상',
        'BREATH_ISSUE' => '호흡 이상',
        'INACTIVITY' => '미활동 감지',
        'SOS' => 'SOS 신호',
        _ => '이상 감지',
      };

  Future<void> _showLogoutDialog(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await UserApi.instance.logout();
    } catch (_) {}
    await AuthStorage.clear();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final emergencyAsync = ref.watch(emergencyEventProvider);
    final vitalsAsync = ref.watch(vitalsStreamProvider);
    final guardiansAsync = ref.watch(guardiansProvider);
    final deviceAsync = ref.watch(deviceStatusProvider);

    // 실제 응급 이벤트 감지 시 애니메이션 트리거
    if (!kDemoMode) {
      ref.listen(emergencyEventProvider, (prev, next) {
        final hasEmergency = next.valueOrNull != null;
        final hadEmergency = prev?.valueOrNull != null;
        if (hasEmergency && !hadEmergency && mounted) {
          setState(() {
            _demoEmergency = true;
            _showNotification = true;
          });
          _pulseController.repeat(reverse: true);
          Timer(const Duration(seconds: 8), () {
            if (mounted) setState(() => _showNotification = false);
          });
        } else if (!hasEmergency && hadEmergency && mounted) {
          setState(() => _demoEmergency = false);
          _pulseController.stop();
          _pulseController.reset();
        }
      });
    }

    final isEmergency = kDemoMode
        ? _demoEmergency
        : (_demoEmergency || emergencyAsync.valueOrNull != null);
    final statusMessage = kDemoMode
        ? (_demoEmergency ? _eventTypeLabel(DependentDemoData.emergencyType) : '정상')
        : _eventTypeLabel(emergencyAsync.valueOrNull?.eventType);
    final displayName = kDemoMode
        ? DependentDemoData.name
        : (profileAsync.valueOrNull?.name ?? '사용자');
    final heartRate = kDemoMode
        ? _heartRate.toString()
        : vitalsAsync.valueOrNull?.heartRate?.toString() ?? '--';
    final breathRate = kDemoMode
        ? _breathRate.toString()
        : vitalsAsync.valueOrNull?.breathRate?.toString() ?? '--';

    // SSE 데이터가 실시간으로 오는 중이면 심박·호흡 센서 연결됨으로 판단
    final sseActive = !kDemoMode && vitalsAsync.hasValue && vitalsAsync.valueOrNull != null;
    final sseHasHeart = sseActive && (vitalsAsync.valueOrNull?.heartRate != null);

    final deviceStatus = deviceAsync.valueOrNull;
    final deviceConnected = kDemoMode
        ? DependentDemoData.raspberryConnected
        : (sseActive || (deviceStatus?.raspberryConnected ?? false));
    final heartSensorConnected = kDemoMode
        ? DependentDemoData.raspberryConnected
        : (sseHasHeart || (deviceStatus?.heartSensorConnected ?? false));
    final fallSensorConnected = kDemoMode
        ? DependentDemoData.raspberryConnected
        : (deviceStatus?.fallSensorConnected ?? false);

    return Stack(
      children: [
        Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$displayName님',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        leadingWidth: 120,
        title: _StatusBadge(
          isEmergency: isEmergency,
          isOffline: !deviceConnected && !isEmergency,
          message: isEmergency
              ? statusMessage
              : (!deviceConnected ? '오프라인' : '정상'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationCenterPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(guardiansProvider);
          ref.invalidate(emergencyEventProvider);
          ref.invalidate(deviceStatusProvider);
        },
        color: AppColors.primaryGreen,
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── 실시간 생체 데이터 ──────────────────────────────────
                _SectionLabel('실시간 생체 데이터'),
                const SizedBox(height: 10),
                _BiometricRow(heartRate: heartRate, breathRate: breathRate),

                const SizedBox(height: 24),

                // ── 긴급 호출 ───────────────────────────────────────────
                _SectionLabel('긴급 호출'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _EmergencyButton(
                        label: '119 신고',
                        subLabel: '응급 신고',
                        icon: Icons.local_hospital_rounded,
                        color: AppColors.alertRed,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EmergencyButton(
                        label: '보호자 호출',
                        subLabel: '즉시 연락',
                        icon: Icons.phone_in_talk_rounded,
                        color: AppColors.primaryGreen,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 센서 연결 상태 ──────────────────────────────────────
                _SectionLabel('센서 연결 상태'),
                const SizedBox(height: 10),
                _DevicePanel(
                  raspberryConnected: deviceConnected,
                  heartSensorConnected: heartSensorConnected,
                  fallSensorConnected: fallSensorConnected,
                ),

                const SizedBox(height: 24),

                // ── 오늘의 활동 ─────────────────────────────────────────
                _SectionLabel('오늘의 활동'),
                const SizedBox(height: 10),
                _ActivityCard(
                  sleep: kDemoMode ? DependentDemoData.sleep : '--',
                  activity: kDemoMode ? DependentDemoData.activity : '--',
                  outing: kDemoMode ? DependentDemoData.outing : '--',
                ),

                const SizedBox(height: 24),

                // ── 등록된 보호자 ───────────────────────────────────────
                Row(
                  children: [
                    _SectionLabel('등록된 보호자'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GuardianRegisterPage()),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.person_add_outlined,
                          size: 15, color: AppColors.primaryGreen),
                      label: const Text(
                        '초대하기',
                        style: TextStyle(color: AppColors.primaryGreen, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Builder(builder: (context) {
                  final list = kDemoMode
                      ? DependentDemoData.guardians
                      : (guardiansAsync.valueOrNull ?? []);
                  if (!kDemoMode && guardiansAsync.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (list.isEmpty) {
                    return _EmptyGuardians(
                      onInvite: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GuardianRegisterPage()),
                      ),
                    );
                  }
                  return Column(
                    children: list
                        .map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _GuardianCard(
                                name: g.name,
                                relation: g.relation,
                                phone: g.phone,
                                isPrimary: g.isPrimary,
                              ),
                            ))
                        .toList(),
                  );
                }),

              ]),
            ),
          ),
        ],
      ),
        ),
        ), // RefreshIndicator

        // ── 빨간 테두리 번쩍 효과 ──────────────────────────────────────
        if (_demoEmergency)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                final opacity = _pulseAnimation.value;
                return Stack(
                  children: [
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.danger.withValues(alpha: opacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.danger.withValues(alpha: opacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0, bottom: 0, left: 0,
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.danger.withValues(alpha: opacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0, bottom: 0, right: 0,
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              AppColors.danger.withValues(alpha: opacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        // ── 실시간 알림 배너 ────────────────────────────────────────────
        if (_showNotification)
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: _EmergencyNotificationBanner(
                message: '심박수 이상 감지 — ${_heartRate}bpm\n보호자에게 자동으로 알림을 전송했습니다.',
                onDismiss: () => setState(() => _showNotification = false),
              ),
            ),
          ),
      ],
    );
  }
}

// ── 섹션 라벨 ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

// ── 생체 데이터 ──────────────────────────────────────────────────────────────

class _BiometricRow extends StatelessWidget {
  const _BiometricRow({required this.heartRate, required this.breathRate});
  final String heartRate;
  final String breathRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BiometricCard(
            label: '심박수',
            value: heartRate,
            unit: 'bpm',
            icon: Icons.favorite_rounded,
            iconColor: AppColors.heartRate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BiometricCard(
            label: '호흡수',
            value: breathRate,
            unit: '/min',
            icon: Icons.air_rounded,
            iconColor: AppColors.breathRate,
          ),
        ),
      ],
    );
  }
}

class _BiometricCard extends StatelessWidget {
  const _BiometricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 긴급 버튼 ────────────────────────────────────────────────────────────────

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String subLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text(subLabel,
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

// ── 센서 패널 ────────────────────────────────────────────────────────────────

class _DevicePanel extends StatelessWidget {
  const _DevicePanel({
    required this.raspberryConnected,
    required this.heartSensorConnected,
    required this.fallSensorConnected,
  });

  final bool raspberryConnected;
  final bool heartSensorConnected;
  final bool fallSensorConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.developer_board_rounded,
                    size: 20, color: Color(0xFF555555)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '라즈베리파이',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Raspberry Pi 4',
                    style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
              const Spacer(),
              _ConnBadge(connected: raspberryConnected),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          _SensorRow(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.heartRate,
            label: '심박/호흡 센서',
            sublabel: 'MR60BHA2',
            connected: heartSensorConnected,
          ),
          const SizedBox(height: 12),
          _SensorRow(
            icon: Icons.directions_run_rounded,
            iconColor: AppColors.primaryGreen,
            label: '낙상 감지 센서',
            sublabel: 'MR60FDA2',
            connected: fallSensorConnected,
          ),
        ],
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.connected,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
            Text(sublabel,
                style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
          ],
        ),
        const Spacer(),
        _ConnBadge(connected: connected, small: true),
      ],
    );
  }
}

class _ConnBadge extends StatelessWidget {
  const _ConnBadge({required this.connected, this.small = false});
  final bool connected;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.primaryGreen : const Color(0xFFBBBBBB);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            connected ? '연결됨' : '연결 안됨',
            style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 활동 카드 ────────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.sleep,
    required this.activity,
    required this.outing,
  });

  final String sleep;
  final String activity;
  final String outing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActivityItem(icon: Icons.nightlight_round, label: '수면', value: sleep),
          _ActivityItem(icon: Icons.directions_walk, label: '활동', value: activity),
          _ActivityItem(icon: Icons.exit_to_app, label: '외출', value: outing),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primaryGreen),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

// ── 보호자 카드 ──────────────────────────────────────────────────────────────

class _EmptyGuardians extends StatelessWidget {
  const _EmptyGuardians({required this.onInvite});
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onInvite,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.person_add_outlined,
                size: 32, color: AppColors.primaryGreen.withValues(alpha: 0.6)),
            const SizedBox(height: 10),
            const Text(
              '등록된 보호자가 없습니다',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '탭하여 보호자를 초대하세요',
              style: TextStyle(
                  color: AppColors.primaryGreen.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상태 배지 ────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isEmergency,
    required this.message,
    this.isOffline = false,
  });
  final bool isEmergency;
  final bool isOffline;
  final String message;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isEmergency
        ? AppColors.alertRed
        : isOffline
            ? const Color(0xFF9E9E9E)
            : AppColors.primaryGreen;
    final IconData icon = isEmergency
        ? Icons.error_outline
        : isOffline
            ? Icons.wifi_off
            : Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardianCard extends StatelessWidget {
  const _GuardianCard({
    required this.name,
    required this.relation,
    required this.phone,
    required this.isPrimary,
  });

  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$name ($relation)',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '주 보호자',
                          style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(phone, style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
        ],
      ),
    );
  }
}

// ── 응급 알림 배너 ────────────────────────────────────────────────────────────

class _EmergencyNotificationBanner extends StatefulWidget {
  const _EmergencyNotificationBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  State<_EmergencyNotificationBanner> createState() =>
      _EmergencyNotificationBannerState();
}

class _EmergencyNotificationBannerState
    extends State<_EmergencyNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: const Icon(Icons.close, color: Colors.white70, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
