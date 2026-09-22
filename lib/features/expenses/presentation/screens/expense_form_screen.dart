import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/receipt_parser.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  final ParsedReceiptData? scannedData;
  final ExpenseModel? initialExpense;

  const ExpenseFormScreen({
    super.key,
    this.scannedData,
    this.initialExpense,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late String _selectedCategoryId;
  String _selectedPaymentMethod = 'QRIS';
  bool _showRawOcr = false;
  bool _isSaving = false;

  final List<String> _paymentMethods = [
    'QRIS',
    'Cash',
    'Kartu Kredit',
    'Kartu Debit',
    'Transfer Bank',
    'E-Wallet',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialExpense != null) {
      final exp = widget.initialExpense!;
      _merchantController = TextEditingController(text: exp.merchant);
      _amountController = TextEditingController(text: exp.amount.toStringAsFixed(0));
      _notesController = TextEditingController(text: exp.notes ?? '');
      _selectedDate = exp.date;
      _selectedCategoryId = exp.categoryId;
      _selectedPaymentMethod = exp.payment_method;
    } else if (widget.scannedData != null) {
      final data = widget.scannedData!;
      _merchantController = TextEditingController(text: data.merchantName);
      _amountController = TextEditingController(
        text: data.amount > 0 ? data.amount.toStringAsFixed(0) : '',
      );
      _notesController = TextEditingController();
      _selectedDate = data.date;
      _selectedCategoryId = data.categoryId;
    } else {
      _merchantController = TextEditingController();
      _amountController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedCategoryId = 'groceries';
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    AppHaptic.mediumImpact();

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    final expense = ExpenseModel(
      id: widget.initialExpense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      merchant: _merchantController.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      payment_method: _selectedPaymentMethod,
      rawOcr: widget.scannedData?.rawText ?? widget.initialExpense?.rawOcr,
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    if (widget.initialExpense != null) {
      await provider.updateExpense(expense);
    } else {
      await provider.addExpense(expense);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialExpense != null
                ? 'Pengeluaran berhasil diperbarui ✨'
                : 'Pengeluaran berhasil disimpan! 🧾',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialExpense != null ? 'Edit Transaksi' : 'Review Resi Belanja'),
        actions: [
          if (widget.initialExpense != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Transaksi?'),
                    content: const Text('Data transaksi ini akan dihapus secara permanen.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await Provider.of<ExpenseProvider>(context, listen: false)
                      .deleteExpense(widget.initialExpense!.id);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.scannedData != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAccentSubtle : AppColors.lightAccentSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Data diekstrak otomatis oleh AI On-Device OCR. Silakan periksa kembali sebelum menyimpan.',
                            style: AppTypography.bodySmall(isDark: isDark).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Merchant Name
                CustomTextField(
                  label: 'Nama Toko / Merchant',
                  hintText: 'Contoh: Alfamart, Starbucks',
                  controller: _merchantController,
                  prefixIcon: Icons.store_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama toko wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // Amount
                CustomTextField(
                  label: 'Nominal Total (Rp)',
                  hintText: '0',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
                    if (double.tryParse(v) == null) return 'Masukkan angka yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Selector
                Text(
                  'Tanggal Transaksi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 20,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormatter.formatFull(_selectedDate),
                              style: AppTypography.bodyMedium(isDark: isDark),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down_rounded),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Selection Grid
                Text(
                  'Kategori Pengeluaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: CategoryModel.categories.map((cat) {
                    final isSelected = cat.id == _selectedCategoryId;
                    return InkWell(
                      onTap: () {
                        AppHaptic.selectionClick();
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color.withOpacity(0.2)
                              : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? cat.color
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 18, color: isSelected ? cat.color : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                            const SizedBox(width: 8),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Payment Method Dropdown
                Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.credit_card_rounded),
                  ),
                  items: _paymentMethods.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPaymentMethod = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                CustomTextField(
                  label: 'Catatan Tambahan (Opsional)',
                  hintText: 'Contoh: Roti, susu, beli pas diskon',
                  controller: _notesController,
                  prefixIcon: Icons.notes_rounded,
                ),
                const SizedBox(height: 24),

                // Raw OCR Toggle Expander
                if (widget.scannedData?.rawText != null) ...[
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showRawOcr = !_showRawOcr;
                      });
                    },
                    icon: Icon(_showRawOcr ? Icons.expand_less : Icons.expand_more),
                    label: Text(_showRawOcr ? 'Sembunyikan Teks Raw OCR' : 'Lihat Hasil Raw OCR'),
                  ),
                  if (_showRawOcr)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.scannedData!.rawText,
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Submit Button
                CustomButton(
                  label: widget.initialExpense != null ? 'Simpan Perubahan' : 'Simpan Transaksi',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isSaving,
                  onPressed: _saveExpense,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
