import 'package:flutter/material.dart';
import 'package:mobile_reporting/models/metric_decimal.dart';
import 'package:mobile_reporting/models/metric_int.dart';

/// A reusable metric card widget for displaying dashboard metrics with delta comparison
class DashboardMetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String formattedValue;
  final double deltaPercent;
  final bool hasChange;
  final bool isLarge;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.formattedValue,
    required this.deltaPercent,
    required this.hasChange,
    this.isLarge = false,
  });

  /// Factory constructor for MetricDecimal with currency formatting
  factory DashboardMetricCard.fromDecimal({
    required String title,
    required IconData icon,
    required MetricDecimal metric,
    required String currency,
    bool isLarge = false,
  }) {
    return DashboardMetricCard(
      title: title,
      icon: icon,
      formattedValue: '$currency${metric.value.toStringAsFixed(2)}',
      deltaPercent: metric.deltaPercent,
      hasChange: metric.hasChange,
      isLarge: isLarge,
    );
  }

  /// Factory constructor for MetricDecimal with percentage formatting
  factory DashboardMetricCard.fromDecimalPercent({
    required String title,
    required IconData icon,
    required MetricDecimal metric,
    bool isLarge = false,
  }) {
    return DashboardMetricCard(
      title: title,
      icon: icon,
      formattedValue: '${metric.value.toStringAsFixed(1)}%',
      deltaPercent: metric.deltaPercent,
      hasChange: metric.hasChange,
      isLarge: isLarge,
    );
  }

  /// Factory constructor for MetricInt
  factory DashboardMetricCard.fromInt({
    required String title,
    required IconData icon,
    required MetricInt metric,
    bool isLarge = false,
  }) {
    return DashboardMetricCard(
      title: title,
      icon: icon,
      formattedValue: metric.value.toString(),
      deltaPercent: metric.deltaPercent,
      hasChange: metric.hasChange,
      isLarge: isLarge,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isPositive = deltaPercent > 0;
    final arrowSize = isLarge ? 44.0 : 20.0;
    final valueSize = isLarge ? 68.0 : 24.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: isLarge ? 22 : 20,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isLarge ? 20 : 15,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          if (isLarge) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          ] else
            const SizedBox(height: 12),
          
          Expanded(
            child: Column(
              mainAxisAlignment: isLarge ? MainAxisAlignment.center : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Value with arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasChange) ...[
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: arrowSize,
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formattedValue,
                          style: TextStyle(
                            fontSize: valueSize,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Percentage change
                if (hasChange) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : '-'}${deltaPercent.abs().toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: isLarge ? 20 : 12,
                      color: isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
