import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../../../services/export_service.dart';

import '../../../expenses/presentation/providers/expense_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Anggaran Bulanan'),
        content: CustomTextField(
          label: 'Nominal Anggaran (Rp)',
          controller: controller,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.account_balance_wallet_rounded,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBudget = double.tryParse(controller.text.trim());
              if (newBudget != null && newBudget > 0) {
                provider.setMonthlyBudget(newBudget);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Keamanan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Section 1: Financial Goal & Budget
            Text(
              'ANGGARAN & TARGET',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => _showBudgetDialog(context, expenseProvider),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wallet_rounded, color: AppColors.lightAccent),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Batas Anggaran Bulanan', style: AppTypography.titleSmall(isDark: isDark)),
                          Text(
                            CurrencyFormatter.format(expenseProvider.monthlyBudget),
                            style: AppTypography.bodySmall(isDark: isDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.edit_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Security & Biometrics
            Text(
              'KEAMANAN',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.info),
                title: Text('Kunci Biometrik (FaceID / Fingerprint)', style: AppTypography.titleSmall(isDark: isDark)),
                subtitle: Text('Meminta otentikasi saat membuka kembali aplikasi', style: AppTypography.bodySmall(isDark: isDark)),
                value: settings.isBiometricsEnabled,
                onChanged: (val) {
                  AppHaptic.selectionClick();
                  settings.toggleBiometrics(val);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Daily Reminders
            Text(
              'NOTIFIKASI PENGINGAT',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_active_rounded, color: AppColors.food),
                    title: Text('Pengingat Harian', style: AppTypography.titleSmall(isDark: isDark)),
                    subtitle: Text('Jadwal notifikasi lokal pencatatan resi', style: AppTypography.bodySmall(isDark: isDark)),
                    value: settings.isDailyReminderEnabled,
                    onChanged: (val) {
                      AppHaptic.selectionClick();
                      settings.toggleDailyReminder(val);
                    },
                  ),
                  if (settings.isDailyReminderEnabled) ...[
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Waktu Pengingat', style: AppTypography.bodyMedium(isDark: isDark)),
                      trailing: Text(
                        '${settings.reminderTime.hour.toString().padLeft(2, '0')}:${settings.reminderTime.minute.toString().padLeft(2, '0')}',
                        style: AppTypography.labelBold(isDark: isDark),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: settings.reminderTime,
                        );
                        if (time != null) {
                          settings.setReminderTime(time);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: Theme Mode
            Text(
              'TAMPILAN & AESTHETIC',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema Aplikasi', style: AppTypography.titleSmall(isDark: isDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Sistem')),
                          selected: settings.themeMode == ThemeMode.system,
                          onSelected: (_) => settings.setThemeMode(ThemeMode.system),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Terang')),
                          selected: settings.themeMode == ThemeMode.light,
                          onSelected: (_) => settings.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Gelap')),
                          selected: settings.themeMode == ThemeMode.dark,
                          onSelected: (_) => settings.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 5: Data & Export
            Text(
              'DATA & EKSPOR',
              style: AppTypography.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () {
                AppHaptic.mediumImpact();
                final csv = ExportService.generateCSV(expenseProvider.allExpenses);
                Share.share(csv, subject: 'SnapCost_Data.csv');
              },
              child: Row(
                children: [
                  const Icon(Icons.ios_share_rounded, color: AppColors.shopping),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ekspor Transaksi ke CSV', style: AppTypography.titleSmall(isDark: isDark)),
                        Text('Simpan backup data transaksi dalam format Excel / CSV', style: AppTypography.bodySmall(isDark: isDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // About Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'SnapCost v1.0.0',
                    style: AppTypography.bodySmall(isDark: isDark).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Clean & Effortless Expense Scanner',
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
