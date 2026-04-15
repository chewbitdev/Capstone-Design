import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/biometric_data.dart';
import '../../domain/entities/biometric_history.dart';
import '../providers/biometric_history_provider.dart';
import '../providers/guardian_provider.dart';

class BiometricHistoryPage extends ConsumerStatefulWidget {
  const BiometricHistoryPage({super.key, required this.wardId, required this.wardName});

  final String wardId;
  final String wardName;

  @override
  ConsumerState<BiometricHistoryPage> createState() => _BiometricHistoryPageState();
}

class _BiometricHistoryPageState extends ConsumerState<BiometricHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 현재 표시할 지표: 0=심박수, 1=호흡수, 2=산소포화도
  int _metricIndex = 0;

  static const _metrics = ['심박수', '호흡수', '산소포화도'];
  static const _units = ['bpm', '회/분', '%'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _getValue(BiometricRecord r) => switch (_metricIndex) {
        0 => r.heartRate.toDouble(),
        1 => r.respiratoryRate.toDouble(),
        _ => r.spO2,
      };

  double _getValue2(BiometricData d) => switch (_metricIndex) {
        0 => d.heartRate.toDouble(),
        1 => d.respiratoryRate.toDouble(),
        _ => d.spO2,
      };

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(biometricProvider(widget.wardId));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.wardName} 생체 데이터')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 값
          _CurrentValueSection(
            current: current,
            metricIndex: _metricIndex,
            getValue: current != null ? () => _getValue2(current) : null,
            unit: _units[_metricIndex],
            label: _metrics[_metricIndex],
          ),

          const Divider(),

          // 지표 선택
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('심박수')),
                ButtonSegment(value: 1, label: Text('호흡수')),
                ButtonSegment(value: 2, label: Text('산소포화도')),
              ],
              selected: {_metricIndex},
              onSelectionChanged: (s) => setState(() => _metricIndex = s.first),
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // 탭 (일별/주별/월별)
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '오늘'),
              Tab(text: '이번 주'),
              Tab(text: '이번 달'),
            ],
          ),

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
                ),
                _ChartTab(
                  wardId: widget.wardId,
                  period: _Period.weekly,
                  metricIndex: _metricIndex,
                  getValue: _getValue,
                  unit: _units[_metricIndex],
                ),
                _ChartTab(
                  wardId: widget.wardId,
                  period: _Period.monthly,
                  metricIndex: _metricIndex,
                  getValue: _getValue,
                  unit: _units[_metricIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 현재 값 섹션 ────────────────────────────────────────────────────────────

class _CurrentValueSection extends StatelessWidget {
  const _CurrentValueSection({
    required this.current,
    required this.metricIndex,
    required this.getValue,
    required this.unit,
    required this.label,
  });

  final BiometricData? current;
  final int metricIndex;
  final double Function()? getValue;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final value = getValue?.call();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('현재 $label',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value != null ? value.toStringAsFixed(metricIndex == 2 ? 1 : 0) : '--',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(unit, style: const TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          if (current != null && current!.isActive)
            const Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.green),
                SizedBox(width: 4),
                Text('실시간', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            )
          else
            const Text('오프라인', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── 차트 탭 ─────────────────────────────────────────────────────────────────

enum _Period { daily, weekly, monthly }

class _ChartTab extends ConsumerWidget {
  const _ChartTab({
    required this.wardId,
    required this.period,
    required this.metricIndex,
    required this.getValue,
    required this.unit,
  });

  final String wardId;
  final _Period period;
  final int metricIndex;
  final double Function(BiometricRecord) getValue;
  final String unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = switch (period) {
      _Period.daily => ref.watch(dailyRecordsProvider(wardId)),
      _Period.weekly => ref.watch(weeklyRecordsProvider(wardId)),
      _Period.monthly => ref.watch(monthlyRecordsProvider(wardId)),
    };

    final values = records.map(getValue).toList();
    final minVal = (values.reduce((a, b) => a < b ? a : b) - 5).clamp(0, 300).toDouble();
    final maxVal = values.reduce((a, b) => a > b ? a : b) + 5;

    final spots = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), getValue(e.value));
    }).toList();

    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 통계 요약
        Row(
          children: [
            _StatChip(label: '평균', value: avg.toStringAsFixed(metricIndex == 2 ? 1 : 0), unit: unit),
            const SizedBox(width: 8),
            _StatChip(label: '최소', value: min.toStringAsFixed(metricIndex == 2 ? 1 : 0), unit: unit),
            const SizedBox(width: 8),
            _StatChip(label: '최대', value: max.toStringAsFixed(metricIndex == 2 ? 1 : 0), unit: unit),
          ],
        ),
        const SizedBox(height: 16),

        // 차트
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minVal,
              maxY: maxVal,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _bottomInterval(records.length),
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= records.length) return const SizedBox();
                      return Text(
                        _bottomLabel(records[idx].time, period),
                        style: const TextStyle(fontSize: 9),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: FlDotData(show: records.length <= 7),
                  barWidth: 2,
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    final idx = s.x.toInt();
                    final record = records[idx];
                    return LineTooltipItem(
                      '${_bottomLabel(record.time, period)}\n${s.y.toStringAsFixed(metricIndex == 2 ? 1 : 0)} $unit',
                      const TextStyle(fontSize: 11),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        const Divider(),

        // 데이터 목록
        ...records.reversed.map((r) => ListTile(
              dense: true,
              title: Text(_fullLabel(r.time, period)),
              trailing: Text(
                '${getValue(r).toStringAsFixed(metricIndex == 2 ? 1 : 0)} $unit',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )),
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

  String _weekday(int w) =>
      ['월', '화', '수', '목', '금', '토', '일'][w - 1];
}

// ── 통계 칩 ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text('$value $unit', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
