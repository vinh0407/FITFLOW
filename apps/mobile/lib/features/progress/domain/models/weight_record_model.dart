enum WeightTrend {
  increase,
  decrease,
  stable,
}

enum WeightPeriod {
  weekly,
  monthly,
  threeMonths,
  sixMonths,
  yearly,
}

class WeightPoint {
  const WeightPoint({
    required this.label,
    required this.weightKg,
    this.isActive = false,
  });

  final String label;
  final double weightKg;
  final bool isActive;
}

class WeightAnalysis {
  const WeightAnalysis({
    required this.currentWeight,
    required this.previousWeight,
    required this.percentageChange,
    required this.trend,
    required this.period,
    required this.points,
  });

  final double currentWeight;
  final double previousWeight;
  final double percentageChange;
  final WeightTrend trend;
  final WeightPeriod period;
  final List<WeightPoint> points;

  String get periodLabel {
    switch (period) {
      case WeightPeriod.weekly:
        return 'Weekly';
      case WeightPeriod.monthly:
        return 'Monthly';
      case WeightPeriod.threeMonths:
        return '3 Months';
      case WeightPeriod.sixMonths:
        return '6 Months';
      case WeightPeriod.yearly:
        return 'Yearly';
    }
  }

  String get trendText {
    final absChange = percentageChange.abs().toStringAsFixed(1);
    switch (trend) {
      case WeightTrend.increase:
        return '+$absChange% ▲ Tăng cân';
      case WeightTrend.decrease:
        return '-$absChange% ▼ Giảm cân';
      case WeightTrend.stable:
        return '0.0% ▬ Ổn định';
    }
  }

  static WeightAnalysis calculate({
    required double currentWeight,
    required double previousWeight,
    required WeightPeriod period,
    required List<WeightPoint> points,
  }) {
    final diff = currentWeight - previousWeight;
    final pct = previousWeight > 0 ? (diff / previousWeight) * 100 : 0.0;
    final WeightTrend trend;
    if (pct > 0.05) {
      trend = WeightTrend.increase;
    } else if (pct < -0.05) {
      trend = WeightTrend.decrease;
    } else {
      trend = WeightTrend.stable;
    }

    return WeightAnalysis(
      currentWeight: currentWeight,
      previousWeight: previousWeight,
      percentageChange: pct,
      trend: trend,
      period: period,
      points: points,
    );
  }
}

class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.date,
    required this.weightKg,
    this.unit = 'kg',
    this.notes = '',
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final String unit;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'unit': unit,
        'notes': notes,
      };

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: '${json['id'] ?? ''}',
        date: DateTime.tryParse('${json['date']}') ?? DateTime.now(),
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70.0,
        unit: '${json['unit'] ?? 'kg'}',
        notes: '${json['notes'] ?? ''}',
      );
}
