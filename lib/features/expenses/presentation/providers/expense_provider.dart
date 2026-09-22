import 'package:flutter/material.dart';
import '../../../../services/database_service.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  double _monthlyBudget = 5000000.0; // Default Rp 5,000,000 budget

  List<ExpenseModel> get expenses => _filteredExpenses();
  List<ExpenseModel> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  double get monthlyBudget => _monthlyBudget;

  ExpenseProvider() {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await DatabaseService.instance.getAllExpenses();
      final savedBudgetStr = await DatabaseService.instance.getSetting('monthly_budget');
      if (savedBudgetStr != null) {
        _monthlyBudget = double.tryParse(savedBudgetStr) ?? 5000000.0;
      }
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double newBudget) async {
    _monthlyBudget = newBudget;
    await DatabaseService.instance.saveSetting('monthly_budget', newBudget.toString());
    notifyListeners();
  }

  List<ExpenseModel> _filteredExpenses() {
    return _expenses.where((exp) {
      final matchesSearch = _searchQuery.isEmpty ||
          exp.merchant.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exp.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesCategory = _selectedCategoryFilter == null || exp.categoryId == _selectedCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  double get totalExpenseCurrentMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get budgetProgressPercentage {
    if (_monthlyBudget <= 0) return 0.0;
    final progress = totalExpenseCurrentMonth / _monthlyBudget;
    return progress.clamp(0.0, 1.0);
  }

  Map<CategoryModel, double> get categoryTotalsCurrentMonth {
    final now = DateTime.now();
    final Map<CategoryModel, double> totals = {};

    final currentMonthExpenses = _expenses.where(
      (e) => e.date.year == now.year && e.date.month == now.month,
    );

    for (final exp in currentMonthExpenses) {
      final cat = exp.getCategory();
      totals[cat] = (totals[cat] ?? 0.0) + exp.amount;
    }

    return totals;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await DatabaseService.instance.insertExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await DatabaseService.instance.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await DatabaseService.instance.deleteExpense(id);
    await loadExpenses();
  }
}
