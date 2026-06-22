class GraphPoint {
  const GraphPoint({required this.label, required this.value});

  final String label;
  final int value;

  factory GraphPoint.fromJson(Map<String, dynamic> json) => GraphPoint(
        label: json['label'] as String,
        value: (json['value'] as num).toInt(),
      );
}

class VitalStats {
  const VitalStats({
    required this.avg,
    required this.min,
    required this.max,
    required this.graphData,
    required this.detailList,
  });

  final int avg;
  final int min;
  final int max;
  final List<GraphPoint> graphData;
  final List<GraphPoint> detailList;

  factory VitalStats.fromJson(Map<String, dynamic> json) => VitalStats(
        avg: (json['avg'] as num).toInt(),
        min: (json['min'] as num).toInt(),
        max: (json['max'] as num).toInt(),
        graphData: (json['graphData'] as List<dynamic>)
            .map((e) => GraphPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        detailList: (json['detailList'] as List<dynamic>)
            .map((e) => GraphPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
