import 'package:flutter/material.dart';
import '../../data/models/month_model.dart';
import '../../core/theme/app_theme.dart';

class MonthSelector extends StatelessWidget {
  final List<MonthModel> months;
  final MonthModel? selected;
  final void Function(MonthModel) onChanged;
  final VoidCallback onAddMonth;

  const MonthSelector({super.key, required this.months, required this.selected,
      required this.onChanged, required this.onAddMonth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length + 1,
        itemBuilder: (_, i) {
          if (i == months.length) {
            return GestureDetector(
              onTap: onAddMonth,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentBlue.withOpacity(0.4)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, color: AppColors.accentBlue, size: 16),
                  SizedBox(width: 4),
                  Text('Add', style: TextStyle(color: AppColors.accentBlue, fontSize: 12)),
                ]),
              ),
            );
          }
          final m   = months[i];
          final sel = selected?.id == m.id;
          return GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? AppColors.accentBlue : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? AppColors.accentBlue : AppColors.bgCardBorder),
              ),
              child: Center(child: Text(m.displayName,
                style: TextStyle(
                  color: sel ? Colors.white : AppColors.textSecondary,
                  fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                ))),
            ),
          );
        },
      ),
    );
  }
}
