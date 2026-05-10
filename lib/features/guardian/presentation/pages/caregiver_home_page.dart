import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entities/ward.dart';
import '../providers/guardian_provider.dart';
import '../widgets/ward_status_card.dart';
import 'alert_history_page.dart';
import 'ward_detail_page.dart';

class CaregiverHomePage extends ConsumerWidget {
  const CaregiverHomePage({super.key});

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
            child: const Text('로그아웃',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wards = ref.watch(wardsProvider);
    final alerts = ref.watch(activeAlertsProvider);

    final emergencyCount = wards.where((w) => w.status == WardStatus.emergency).length;
    final warningCount = wards.where((w) => w.status == WardStatus.warning).length;
    final outingCount = wards.where((w) => w.status == WardStatus.outing).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        title: Row(
          children: [
            const Icon(Icons.circle, size: 10, color: AppColors.statusNormal),
            const SizedBox(width: 8),
            Text(
              '${wards.length}명 모니터링 중',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.statusNormal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _showLogoutDialog(context),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlertHistoryPage()),
                ),
              ),
              if (alerts.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${alerts.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 요약 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: '긴급',
                      value: '$emergencyCount건',
                      icon: Icons.warning_rounded,
                      activeColor: AppColors.danger,
                      activeSurface: AppColors.dangerSurface,
                      isActive: emergencyCount > 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: '주의',
                      value: '$warningCount건',
                      icon: Icons.info_outline,
                      activeColor: AppColors.warning,
                      activeSurface: AppColors.warningSurface,
                      isActive: warningCount > 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: '외출',
                      value: '$outingCount명',
                      icon: Icons.exit_to_app,
                      activeColor: AppColors.outing,
                      activeSurface: AppColors.outingSurface,
                      isActive: outingCount > 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 피보호자 목록 헤더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '피보호자 목록',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          // 피보호자 카드 목록
          wards.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_outlined,
                            size: 48, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text(
                          '등록된 피보호자가 없습니다.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => WardStatusCard(
                      ward: wards[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WardDetailPage(ward: wards[i]),
                        ),
                      ),
                    ),
                    childCount: wards.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.activeColor,
    required this.activeSurface,
    required this.isActive,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color activeColor;
  final Color activeSurface;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : AppColors.textHint;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? activeSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? activeColor : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
