import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../../../services/export_service.dart';
import '../../data/models/category_model.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';
import 'expense_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportCSV() {
    AppHaptic.mediumImpact();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final csvContent = ExportService.generateCSV(provider.allExpenses);

    Share.share(
      csvContent,
      subject: 'SnapCost_Riwayat_Pengeluaran.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ExpenseProvider>(context);

    final expenses = provider.expenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            onPressed: _exportCSV,
            tooltip: 'Ekspor CSV',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.download_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: CustomTextField(
                label: '',
                hintText: 'Cari nama toko atau catatan...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
                onChanged: (val) {
                  provider.setSearchQuery(val);
                },
              ),
            ),

            // Horizontal Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: provider.selectedCategoryFilter == null,
                    onSelected: (_) {
                      AppHaptic.selectionClick();
                      provider.setCategoryFilter(null);
                    },
                    selectedColor: isDark ? AppColors.darkAccent : AppColors.lightTextPrimary,
                    labelStyle: TextStyle(
                      color: provider.selectedCategoryFilter == null
                          ? (isDark ? AppColors.darkBackground : Colors.white)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...CategoryModel.categories.map((cat) {
                    final isSelected = provider.selectedCategoryFilter == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: cat.color,
                        onSelected: (_) {
                          AppHaptic.selectionClick();
                          provider.setCategoryFilter(isSelected ? null : cat.id);
                        },
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Transaction List
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada transaksi yang cocok',
                            style: AppTypography.bodyMedium(isDark: isDark),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];

                        // Show date header if first or date changed from previous
                        bool showHeader = false;
                        if (index == 0) {
                          showHeader = true;
                        } else {
                          final prev = expenses[index - 1];
                          final d1 = DateTime(expense.date.year, expense.date.month, expense.date.day);
                          final d2 = DateTime(prev.date.year, prev.date.month, prev.date.day);
                          if (!d1.isAtSameMomentAs(d2)) {
                            showHeader = true;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                                child: Text(
                                  DateFormatter.formatRelative(expense.date),
                                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ExpenseTile(
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
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
