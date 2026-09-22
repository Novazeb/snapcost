import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<CategoryModel> categories = [
    CategoryModel(
      id: 'food',
      name: 'Makanan & Minuman',
      icon: Icons.restaurant_rounded,
      color: AppColors.food,
    ),
    CategoryModel(
      id: 'groceries',
      name: 'Minimarket & Belanja',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.shopping,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transportasi & BBM',
      icon: Icons.directions_car_rounded,
      color: AppColors.transport,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Tagihan & Utilitas',
      icon: Icons.receipt_long_rounded,
      color: AppColors.bills,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Hiburan & Hobi',
      icon: Icons.movie_creation_rounded,
      color: AppColors.entertainment,
    ),
    CategoryModel(
      id: 'health',
      name: 'Kesehatan & Obat',
      icon: Icons.local_hospital_rounded,
      color: AppColors.health,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Belanja Barang',
      icon: Icons.card_giftcard_rounded,
      color: AppColors.shopping,
    ),
    CategoryModel(
      id: 'others',
      name: 'Lain-lain',
      icon: Icons.more_horiz_rounded,
      color: AppColors.others,
    ),
  ];

  static CategoryModel getById(String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => categories.last,
    );
  }
}
