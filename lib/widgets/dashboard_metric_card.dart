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

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.formattedValue,
    required this.deltaPercent,
    required this.hasChange,
  });

  /// Factory constructor for MetricDecimal with currency formatting
  factory DashboardMetricCard.fromDecimal({
    required String title,
    required IconData icon,
    required MetricDecimal metric,
    required String currency,
  }) {
    return DashboardMetricCard(
      title: title,
      icon: icon,
      formattedValue: '$currency${metric.value.toStringAsFixed(2)}',
      deltaPercent: metric.deltaPercent,
      hasChange: metric.hasChange,
    );
  }

  /// Factory constructor for MetricDecimal with percentage formatting
  factory DashboardMetricCard.fromDecimalPercent({
    required String title,
    required IconData icon,
    required MetricDecimal metric,
  }) {
    return DashboardMetricCard(
      title: title,
      icon: icon,
      formattedValue: '${metric.value.toStringAsFixed(1)}%',
      deltaPercent: metric.deltaPercent,
      hasChange: metric.hasChange,
    );
  }

  /// Factory constructor for MetricInt
  factory DashboardMetricCard.fromInt({
    required String title,
    required IconData icon,
    required MetricInt metric,
  }) {
    return DashboardMetricCard(
      title: title,
      icon: icon,
      formattedValue: metric.value.toString(),
      deltaPercent: metric.deltaPercent,
      hasChange: metric.hasChange,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = deltaPercent > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedValue,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasChange)
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${deltaPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
