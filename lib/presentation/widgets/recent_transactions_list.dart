import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const RecentTransactionsList({super.key, required this.expenses});

  static const _catIcons = {
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Miscellaneous': Icons.category_rounded,
    'Shopping': Icons.shopping_bag_rounded,
  };
  static const _catColors = {
    'Food': AppColors.yellow,
    'Transport': AppColors.red,
    'Miscellaneous': AppColors.purple,
    'Shopping': AppColors.accentBlue,
  };

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bgCardBorder)),
        child: const Center(child: Text('No recent transactions',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      );
    }
    return Container(
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bgCardBorder)),
      child: ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bgCardBorder),
        itemBuilder: (_, i) {
          final e = expenses[i];
          final color = _catColors[e.category] ?? AppColors.textSecondary;
          final icon  = _catIcons[e.category]  ?? Icons.receipt_rounded;
          return ListTile(
            leading: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
            title: Text(e.category, style: const TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: Text('Day ${e.day}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            trailing: Text('- ${Formatters.currencyCompact(e.amount)}',
                style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600, fontSize: 13)),
          );
        },
      ),
    );
  }
}
