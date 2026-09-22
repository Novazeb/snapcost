import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../data/models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = expense.getCategory();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptic.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  category.icon,
                  size: 22,
                  color: category.color,
                ),
              ),
              const SizedBox(width: 14),

              // Title & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.merchant,
                      style: AppTypography.titleSmall(isDark: isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          expense.payment_method,
                          style: AppTypography.bodySmall(isDark: isDark).copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text('•', style: AppTypography.bodySmall(isDark: isDark)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              expense.notes!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall(isDark: isDark),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount & Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '- ${CurrencyFormatter.format(expense.amount)}',
                    style: AppTypography.labelBold(
                      isDark: isDark,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormatter.formatTime(expense.date),
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
