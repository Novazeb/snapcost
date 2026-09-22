import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../data/models/category_model.dart';
import '../providers/expense_provider.dart';

class CategoryChart extends StatefulWidget {
  const CategoryChart({super.key});

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ExpenseProvider>(context);
    final categoryTotals = provider.categoryTotalsCurrentMonth;
    final totalSpent = provider.totalExpenseCurrentMonth;

    if (categoryTotals.isEmpty || totalSpent == 0) {
      return CustomCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 40,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada grafik pengeluaran',
                style: AppTypography.bodyMedium(isDark: isDark),
              ),
            ],
          ),
        ),
      );
    }

    final entries = categoryTotals.entries.toList();

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Pengeluaran',
            style: AppTypography.titleSmall(isDark: isDark),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 42,
                    sections: List.generate(entries.length, (i) {
                      final isTouched = i == touchedIndex;
                      final fontSize = isTouched ? 14.0 : 12.0;
                      final radius = isTouched ? 28.0 : 22.0;
                      final entry = entries[i];
                      final pct = (entry.value / totalSpent) * 100;

                      return PieChartSectionData(
                        color: entry.key.color,
                        value: entry.value,
                        title: '${pct.toStringAsFixed(0)}%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: entries.take(4).map((entry) {
                    final pct = (entry.value / totalSpent) * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: entry.key.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(entry.value),
                            style: AppTypography.bodySmall(isDark: isDark).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
