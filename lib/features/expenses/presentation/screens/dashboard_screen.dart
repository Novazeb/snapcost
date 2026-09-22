import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../../scanner/presentation/screens/scanner_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_chart.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';
import 'expense_form_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ExpenseProvider>(context);

    final recentExpenses = provider.allExpenses.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            AppHaptic.lightImpact();
            await provider.loadExpenses();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Header
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkAccentSubtle : AppColors.lightAccentSubtle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  size: 20,
                                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'SnapCost',
                                style: AppTypography.titleLarge(isDark: isDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Clean & Effortless Expense Scanner',
                            style: AppTypography.bodySmall(isDark: isDark),
                          ),
                        ],
                      ),

                      // Settings Gear Button
                      IconButton(
                        onPressed: () {
                          AppHaptic.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Summary Card
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: SummaryCard(),
                ),
              ),

              // Action Banner: Scan AI Receipt
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        AppHaptic.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScannerScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF064E3B), const Color(0xFF1E293B)]
                                : [const Color(0xFF10B981), const Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppColors.darkAccent : AppColors.lightAccent).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.document_scanner_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pindai Resi Sekarang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Ekstraksi otomatis via Google ML Kit AI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Category Breakdown Chart
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: CategoryChart(),
                ),
              ),

              // Recent Transactions Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terakhir',
                        style: AppTypography.titleSmall(isDark: isDark),
                      ),
                      TextButton(
                        onPressed: () {
                          AppHaptic.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransactionListScreen()),
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: AppTypography.labelBold(
                            isDark: isDark,
                            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Transactions List
              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (recentExpenses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Center(
                      child: Text(
                        'Belum ada transaksi. Pindai resi pertama kamu!',
                        style: AppTypography.bodyMedium(isDark: isDark),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = recentExpenses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ExpenseTile(
                            expense: expense,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpenseFormScreen(initialExpense: expense),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: recentExpenses.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
