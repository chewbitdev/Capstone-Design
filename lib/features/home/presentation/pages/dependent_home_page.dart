import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notification/presentation/pages/notification_center_page.dart';
import '../../../guardian/presentation/pages/guardian_register_page.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/dependent_home_provider.dart';

class DependentHomePage extends ConsumerWidget {
  const DependentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final emergencyAsync = ref.watch(emergencyEventProvider);
    final vitalsAsync = ref.watch(vitalsStreamProvider);
    final guardiansAsync = ref.watch(guardiansProvider);

    final isEmergency = emergencyAsync.valueOrNull != null;
    final statusMessage = isEmergency
        ? (emergencyAsync.value?.eventType ?? '이상 감지')
        : '정상';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: _StatusBadge(
          isEmergency: isEmergency,
          message: isEmergency ? statusMessage : '정상',
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
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 인사 카드
            profileAsync.when(
              data: (profile) => _GreetingCard(
                name: profile?.name ?? '사용자',
                status: profile?.status ?? 'NORMAL',
              ),
              loading: () => _GreetingCard(name: '...', status: 'NORMAL'),
              error: (_, __) => _GreetingCard(name: '사용자', status: 'NORMAL'),
            ),
            const SizedBox(height: 24),

            // 실시간 생체 데이터
            const _SectionTitle('실시간 생체 데이터'),
            const SizedBox(height: 12),
            vitalsAsync.when(
              data: (vital) => Row(
                children: [
                  Expanded(
                    child: _BiometricCard(
                      label: '심박수',
                      value: vital.heartRate?.toString() ?? '--',
                      unit: 'bpm',
                      icon: Icons.favorite,
                      iconColor: AppColors.heartRate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BiometricCard(
                      label: '호흡수',
                      value: vital.breathRate?.toString() ?? '--',
                      unit: '/min',
                      icon: Icons.air,
                      iconColor: AppColors.breathRate,
                    ),
                  ),
                ],
              ),
              loading: () => const Row(
                children: [
                  Expanded(
                    child: _BiometricCard(
                      label: '심박수', value: '--', unit: 'bpm',
                      icon: Icons.favorite, iconColor: AppColors.heartRate,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _BiometricCard(
                      label: '호흡수', value: '--', unit: '/min',
                      icon: Icons.air, iconColor: AppColors.breathRate,
                    ),
                  ),
                ],
              ),
              error: (_, __) => const Row(
                children: [
                  Expanded(
                    child: _BiometricCard(
                      label: '심박수', value: '--', unit: 'bpm',
                      icon: Icons.favorite, iconColor: AppColors.heartRate,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _BiometricCard(
                      label: '호흡수', value: '--', unit: '/min',
                      icon: Icons.air, iconColor: AppColors.breathRate,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const _SectionTitle('디바이스 상태'),
            const SizedBox(height: 12),
            _DeviceStatusCard(),

            const SizedBox(height: 28),
            const _SectionTitle('긴급 호출'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EmergencyButton(
                    label: '119 신고',
                    subLabel: '응급 신고',
                    icon: Icons.local_hospital,
                    color: AppColors.alertRed,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _EmergencyButton(
                    label: '보호자 호출',
                    subLabel: '즉시 연락',
                    icon: Icons.phone_in_talk,
                    color: AppColors.primaryGreen,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const _SectionTitle('낙상 감지'),
            const SizedBox(height: 12),
            _FallDetectionCard(),

            const SizedBox(height: 28),
            const _SectionTitle('오늘의 활동'),
            const SizedBox(height: 12),
            _ActivityCard(),

            const SizedBox(height: 28),
            Row(
              children: [
                const _SectionTitle('등록된 보호자'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GuardianRegisterPage(),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                  label: const Text(
                    '추가',
                    style: TextStyle(color: AppColors.primaryGreen, fontSize: 14),
                  ),
                ),
              ],
            ),
            guardiansAsync.when(
              data: (guardians) => guardians.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          '등록된 보호자가 없습니다.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: guardians
                          .map(
                            (g) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _GuardianCard(
                                name: g.name,
                                relation: g.relation,
                                phone: g.phone,
                                isPrimary: g.isPrimary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  final String status;

  const _GreetingCard({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 32, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('안녕하세요', style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                '$name 님',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  status == 'NORMAL' ? '정상' : status,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _BiometricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const _BiometricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(unit, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeviceStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.watch, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          const Text('웨어러블 기기',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text('연결 안됨', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _EmergencyButton({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(subLabel,
                style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _FallDetectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.accessibility_new, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('낙상 감지 모니터링',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Text('마지막 감지: 없음',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Text(
            '대기 중',
            style: TextStyle(
                color: AppColors.primaryGreen.withOpacity(0.7),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActivityItem(icon: Icons.nightlight_round, label: '수면', value: '--'),
          _ActivityItem(icon: Icons.directions_walk, label: '활동', value: '--'),
          _ActivityItem(icon: Icons.exit_to_app, label: '외출', value: '--'),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _GuardianCard extends StatelessWidget {
  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;

  const _GuardianCard({
    required this.name,
    required this.relation,
    required this.phone,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.background,
            child: Icon(Icons.person_outline, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$name ($relation)',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  if (isPrimary) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '주 보호자',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              Text(phone,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isEmergency;
  final String message;
  const _StatusBadge({required this.isEmergency, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEmergency ? AppColors.alertRed : AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmergency ? Icons.error_outline : Icons.check_circle_outline,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            message,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
