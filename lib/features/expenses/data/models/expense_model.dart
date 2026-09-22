import 'category_model.dart';

class ExpenseModel {
  final String id;
  final String merchant;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? notes;
  final String payment_method;
  final String? rawOcr;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes,
    this.payment_method = 'QRIS',
    this.rawOcr,
    DateTime? created_at,
  }) : createdAt = created_at ?? DateTime.now();

  CategoryModel getCategory() {
    return CategoryModel.getById(categoryId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'notes': notes,
      'payment_method': payment_method,
      'raw_ocr': rawOcr,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      merchant: map['merchant'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      payment_method: (map['payment_method'] as String?) ?? 'QRIS',
      rawOcr: map['raw_ocr'] as String?,
      created_at: DateTime.parse(map['created_at'] as String),
    );
  }

  ExpenseModel copyWith({
    String? id,
    String? merchant,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? notes,
    String? payment_method,
    String? rawOcr,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      payment_method: payment_method ?? this.payment_method,
      rawOcr: rawOcr ?? this.rawOcr,
      created_at: createdAt ?? this.createdAt,
    );
  }
}
