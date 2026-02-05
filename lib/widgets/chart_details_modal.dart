import 'package:flutter/material.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

class ChartDetailsModal extends StatelessWidget {
  final String title;
  final String currentValueLabel;
  final String currentValueText;
  final String previousValueLabel;
  final String previousValueText;
  final String changeLabel;
  final double percentChange;
  final String closeLabel;
  final Color? currentValueColor;
  final Color? previousValueColor;

  const ChartDetailsModal({
    super.key,
    required this.title,
    required this.currentValueLabel,
    required this.currentValueText,
    required this.previousValueLabel,
    required this.previousValueText,
    required this.changeLabel,
    required this.percentChange,
    required this.closeLabel,
    this.currentValueColor,
    this.previousValueColor,
  });

  static void show({
    required BuildContext context,
    required String title,
    required String currentValueLabel,
    required String currentValueText,
    required String previousValueLabel,
    required String previousValueText,
    required String changeLabel,
    required double percentChange,
    required String closeLabel,
    Color? currentValueColor,
    Color? previousValueColor,
  }) {
    // Use Future.delayed to decouple from the immediate touch event loop,
    // avoiding 'mouse_tracker.dart' assertion errors during rapid interaction.
    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => ChartDetailsModal(
          title: title,
          currentValueLabel: currentValueLabel,
          currentValueText: currentValueText,
          previousValueLabel: previousValueLabel,
          previousValueText: previousValueText,
          changeLabel: changeLabel,
          percentChange: percentChange,
          closeLabel: closeLabel,
          currentValueColor: currentValueColor,
          previousValueColor: previousValueColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = percentChange >= 0;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentValueLabel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              currentValueText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: currentValueColor ?? AppTheme.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              previousValueLabel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              previousValueText,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: previousValueColor ?? Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              changeLabel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isPositive
                                        ? Colors.green
                                        : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: isPositive
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: isPositive
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        closeLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
