import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/biometric_history.dart';
import '../../domain/entities/emergency_alert.dart';
import '../providers/biometric_history_provider.dart';
import '../providers/guardian_provider.dart';

class BiometricHistoryPage extends ConsumerStatefulWidget {
  const BiometricHistoryPage({
    super.key,
    required this.wardId,
    required this.wardName,
  });

  final String wardId;
  final String wardName;

  @override
  ConsumerState<BiometricHistoryPage> createState() =>
      _BiometricHistoryPageState();
}

class _BiometricHistoryPageState extends ConsumerState<BiometricHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _metricIndex = 0;

  static const _metrics = ['심박수', '호흡수'];
  static const _units = ['bpm', '회/분'];
  static const _metricColors = [AppColors.heartRate, AppColors.breathRate];
  static const _metricIcons = [Icons.favorite_rounded, Icons.air_rounded];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _getValue(BiometricRecord r) =>
      _metricIndex == 0 ? r.heartRate.toDouble() : r.respiratoryRate.toDouble();

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(biometricProvider(widget.wardId));
    final isAlertTab = _tabController.index == 3;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.wardName} 생체 데이터',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── 현재 생체 데이터 카드 2개 ──────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _CurrentCard(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.heartRate,
                    label: '심박수',
                    value: current?.isActive == true
                        ? '${current!.heartRate}'
                        : '--',
                    unit: 'bpm',
                    isAbnormal: current?.isHeartRateAbnormal ?? false,
                    isActive: current?.isActive ?? false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CurrentCard(
                    icon: Icons.air_rounded,
                    iconColor: AppColors.breathRate,
                    label: '호흡수',
                    value: current?.isActive == true
                        ? '${current!.respiratoryRate}'
                        : '--',
                    unit: '회/분',
                    isAbnormal: current?.isRespiratoryAbnormal ?? false,
                    isActive: current?.isActive ?? false,
                  ),
                ),
              ],
            ),
          ),

          // ── 지표 선택 (알림 탭 제외) ───────────────────────────────
          if (!isAlertTab)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: List.generate(_metrics.length, (i) {
                  final selected = _metricIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _metricIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? _metricColors[i].withValues(alpha: 0.1)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? _metricColors[i]
                                : AppColors.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_metricIcons[i],
                                size: 14,
                                color: selected
                                    ? _metricColors[i]
                                    : AppColors.textHint),
                            const SizedBox(width: 6),
                            Text(
                              _metrics[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? _metricColors[i]
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // ── 탭바 ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '오늘'),
                Tab(text: '이번 주'),
                Tab(text: '이번 달'),
                Tab(text: '알림 이력'),
              ],
            ),
          ),

          // ── 탭 콘텐츠 ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ChartTab(
                  wardId: widget.wardId,
                  period: _Period.daily,
                  metricIndex: _metricIndex,
                  getValue: _getValue,
                  unit: _units[_metricIndex],
                  color: _metricColors[_metricIndex],
                ),
                _ChartTab(
                  wardId: widget.wardId,
                  period: _Period.weekly,
                  metricIndex: _metricIndex,
                  getValue: _getValue,
                  unit: _units[_metricIndex],
                  color: _metricColors[_metricIndex],
                ),
                _ChartTab(
                  wardId: widget.wardId,
                  period: _Period.monthly,
                  metricIndex: _metricIndex,
                  getValue: _getValue,
                  unit: _units[_metricIndex],
                  color: _metricColors[_metricIndex],
                ),
                _AlertHistoryTab(wardId: widget.wardId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 현재값 카드 ──────────────────────────────────────────────────────────────

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.isAbnormal,
    required this.isActive,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final bool isAbnormal;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final displayColor = isAbnormal ? AppColors.danger : iconColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: displayColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: displayColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: displayColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.statusNormal,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: displayColor,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: displayColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          if (isAbnormal)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '정상 범위 초과',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.danger.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 차트 탭 ──────────────────────────────────────────────────────────────────

enum _Period { daily, weekly, monthly }

class _ChartTab extends ConsumerWidget {
  const _ChartTab({
    required this.wardId,
    required this.period,
    required this.metricIndex,
    required this.getValue,
    required this.unit,
    required this.color,
  });

  final String wardId;
  final _Period period;
  final int metricIndex;
  final double Function(BiometricRecord) getValue;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = switch (period) {
      _Period.daily => ref.watch(dailyRecordsProvider(wardId)),
      _Period.weekly => ref.watch(weeklyRecordsProvider(wardId)),
      _Period.monthly => ref.watch(monthlyRecordsProvider(wardId)),
    };

    if (records.isEmpty) {
      return const Center(
        child: Text('데이터 없음', style: TextStyle(color: AppColors.textHint)),
      );
    }

    final values = records.map(getValue).toList();
    final minVal = (values.reduce((a, b) => a < b ? a : b) - 8).clamp(0, 300).toDouble();
    final maxVal = values.reduce((a, b) => a > b ? a : b) + 8;
    final avg = values.reduce((a, b) => a + b) / values.length;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);

    final spots = records.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), getValue(e.value)))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 통계 요약 카드
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: '평균', value: avg.toStringAsFixed(0), unit: unit, color: color),
              Container(width: 1, height: 36, color: AppColors.border),
              _StatItem(label: '최솟값', value: minV.toStringAsFixed(0), unit: unit, color: AppColors.textSecondary),
              Container(width: 1, height: 36, color: AppColors.border),
              _StatItem(label: '최댓값', value: maxV.toStringAsFixed(0), unit: unit, color: AppColors.danger),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 차트
        Container(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minVal,
                maxY: maxVal,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _bottomInterval(records.length),
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= records.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _bottomLabel(records[idx].time, period),
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.textHint),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.08),
                    ),
                    dotData: FlDotData(
                      show: records.length <= 7,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: color,
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.x.toInt();
                      final record = records[idx];
                      return LineTooltipItem(
                        '${_bottomLabel(record.time, period)}\n${s.y.toStringAsFixed(0)} $unit',
                        const TextStyle(fontSize: 11, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 데이터 목록
        Text(
          '상세 기록',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ...records.reversed.map((r) {
          final val = getValue(r);
          final isHigh = val > (metricIndex == 0 ? 100 : 20);
          final isLow = val < (metricIndex == 0 ? 50 : 12);
          final isAbnormal = isHigh || isLow;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isAbnormal
                    ? AppColors.danger.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isAbnormal ? Icons.warning_rounded : Icons.check_circle_outline,
                  size: 14,
                  color: isAbnormal ? AppColors.danger : AppColors.statusNormal,
                ),
                const SizedBox(width: 8),
                Text(
                  _fullLabel(r.time, period),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${val.toStringAsFixed(0)} $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isAbnormal ? AppColors.danger : color,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  double _bottomInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    return (count / 6).ceilToDouble();
  }

  String _bottomLabel(DateTime t, _Period p) => switch (p) {
        _Period.daily => '${t.hour}시',
        _Period.weekly => _weekday(t.weekday),
        _Period.monthly => '${t.day}일',
      };

  String _fullLabel(DateTime t, _Period p) => switch (p) {
        _Period.daily => '${t.hour.toString().padLeft(2, '0')}:00',
        _Period.weekly => '${t.month}/${t.day} (${_weekday(t.weekday)})',
        _Period.monthly => '${t.month}/${t.day}',
      };

  String _weekday(int w) => ['월', '화', '수', '목', '금', '토', '일'][w - 1];
}

// ── 통계 아이템 ──────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
        Text(unit,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── 알림 이력 탭 ─────────────────────────────────────────────────────────────

class _AlertHistoryTab extends ConsumerWidget {
  const _AlertHistoryTab({required this.wardId});

  final String wardId;

  Color _alertColor(AlertType t) => switch (t) {
        AlertType.fall => AppColors.danger,
        AlertType.sos => AppColors.danger,
        AlertType.heartRateAbnormal => AppColors.warning,
        AlertType.inactivity => AppColors.statusOffline,
        AlertType.outing => AppColors.outing,
        AlertType.invitation => AppColors.primary,
      };

  Color _alertSurface(AlertType t) => switch (t) {
        AlertType.fall => AppColors.dangerSurface,
        AlertType.sos => AppColors.dangerSurface,
        AlertType.heartRateAbnormal => AppColors.warningSurface,
        AlertType.inactivity => const Color(0xFFF5F5F5),
        AlertType.outing => AppColors.outingSurface,
        AlertType.invitation => AppColors.primarySurface,
      };

  IconData _alertIcon(AlertType t) => switch (t) {
        AlertType.fall => Icons.warning_rounded,
        AlertType.sos => Icons.warning_rounded,
        AlertType.heartRateAbnormal => Icons.info_outline,
        AlertType.inactivity => Icons.info_outline,
        AlertType.outing => Icons.exit_to_app,
        AlertType.invitation => Icons.person_add_outlined,
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(allAlertsByWardProvider(wardId));

    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.statusNormal),
            SizedBox(height: 12),
            Text('이상 알림 이력이 없습니다.',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final active = alerts.where((a) => !a.isResolved).toList();
    final resolved = alerts.where((a) => a.isResolved).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (active.isNotEmpty) ...[
          _sectionLabel('미해결 (${active.length}건)'),
          const SizedBox(height: 8),
          ...active.map((a) => _AlertRow(
                alert: a,
                timeAgo: _timeAgo(a.occurredAt),
                color: _alertColor(a.type),
                surface: _alertSurface(a.type),
                icon: _alertIcon(a.type),
              )),
          const SizedBox(height: 16),
        ],
        if (resolved.isNotEmpty) ...[
          _sectionLabel('해결됨 (${resolved.length}건)'),
          const SizedBox(height: 8),
          ...resolved.map((a) => _AlertRow(
                alert: a,
                timeAgo: _timeAgo(a.occurredAt),
                color: AppColors.textHint,
                surface: const Color(0xFFF5F5F5),
                icon: Icons.check_circle_outline,
                isResolved: true,
              )),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      );
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.alert,
    required this.timeAgo,
    required this.color,
    required this.surface,
    required this.icon,
    this.isResolved = false,
  });

  final EmergencyAlert alert;
  final String timeAgo;
  final Color color;
  final Color surface;
  final IconData icon;
  final bool isResolved;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isResolved ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isResolved
              ? AppColors.border
              : color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.type.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isResolved ? FontWeight.normal : FontWeight.w600,
                    color: isResolved
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration:
                        isResolved ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$timeAgo · ${alert.message}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!isResolved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '미해결',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
            ),
        ],
      ),
    );
  }
}
