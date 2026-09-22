import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../../scanner/presentation/screens/scanner_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'dashboard_screen.dart';
import 'expense_form_screen.dart';
import 'transaction_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    TransactionListScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    AppHaptic.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  void _openScanner() {
    AppHaptic.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );
  }

  void _openManualExpenseForm() {
    AppHaptic.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightTextPrimary,
        foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 4,
        icon: const Icon(Icons.document_scanner_rounded, size: 22),
        label: const Text(
          'Pindai Resi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
