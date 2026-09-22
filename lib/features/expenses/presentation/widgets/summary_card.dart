import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/expense_provider.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ExpenseProvider>(context);

    final totalSpent = provider.totalExpenseCurrentMonth;
    final budget = provider.monthlyBudget;
    final progress = provider.budgetProgressPercentage;
    final isOverBudget = totalSpent > budget;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran Bulan Ini',
                style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                      style: AppTypography.bodySmall(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalSpent),
            style: AppTypography.heroAmount(isDark: isDark),
          ),
          const SizedBox(height: 16),

          // Budget Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Anggaran: ${CurrencyFormatter.format(budget)}',
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: AppTypography.labelBold(
                      isDark: isDark,
                      color: isOverBudget
                          ? AppColors.danger
                          : (isDark ? AppColors.darkAccent : AppColors.lightAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget
                        ? AppColors.danger
                        : (isDark ? AppColors.darkAccent : AppColors.lightAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
