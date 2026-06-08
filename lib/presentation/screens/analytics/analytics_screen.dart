import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/month_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _period = 'This Month';
  int _pieTouched = -1;

  final _periods = ['This Month', 'Last Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    return Consumer3<MonthProvider, IncomeProvider, ExpenseProvider>(
      builder: (_, mp, ip, ep, __) {
        final income  = ip.totalIncome;
        final expense = ep.totalAllExpenses;
        final saving  = income - expense;
        final byCategory = ep.byCategory;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgDark,
            leading: const Icon(Icons.menu_rounded, color: AppColors.textSecondary),
            title: const Text('Analytics'), centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Period pills
              _PeriodPills(
                selected: _period,
                options: _periods,
                onChanged: (v) => setState(() => _period = v),
              ),
              const SizedBox(height: 20),

              // Expense by Category header
              const Text('Expense by Category',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),

              // Donut + legend row
              _ExpenseCategoryCard(
                byCategory: byCategory,
                totalExpense: expense,
                touched: _pieTouched,
                onTouch: (i) => setState(() => _pieTouched = i),
              ),
              const SizedBox(height: 24),

              // Monthly Trend
              const Text('Monthly Trend',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              _MonthlyTrendCard(
                months: mp.months,
                selectedId: mp.selectedMonth?.id,
                income: income,
                expense: expense,
              ),
              const SizedBox(height: 24),

              // Income vs Expense Bar
              const Text('Income vs Expenses',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              _IncomeExpenseCard(income: income, expense: expense, saving: saving),
            ]),
          ),
        );
      },
    );
  }
}

// ── Period pills ──────────────────────────────────────────────────────────────
class _PeriodPills extends StatelessWidget {
  final String selected;
  final List<String> options;
  final void Function(String) onChanged;
  const _PeriodPills({required this.selected, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(
        children: options.map((o) {
          final sel = selected == o;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.accentBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(o, textAlign: TextAlign.center,
                    style: TextStyle(
                      color: sel ? Colors.white : AppColors.textSecondary,
                      fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Expense Category Donut Card ───────────────────────────────────────────────
class _ExpenseCategoryCard extends StatelessWidget {
  final Map<String, double> byCategory;
  final double totalExpense;
  final int touched;
  final void Function(int) onTouch;

  const _ExpenseCategoryCard({
    required this.byCategory, required this.totalExpense,
    required this.touched, required this.onTouch,
  });

  static const _colors = [
    AppColors.accentBlue, AppColors.red, AppColors.green,
    AppColors.yellow, AppColors.purple, Color(0xFF06B6D4), Color(0xFFF97316),
  ];
  // Fixed legend for mockup style
  static const _fixedLabels = ['Food', 'Transport', 'Bills', 'Shopping', 'Others'];
  static const _fixedPcts   = [0.32, 0.18, 0.16, 0.14, 0.20];

  @override
  Widget build(BuildContext context) {
    final entries = byCategory.isNotEmpty
        ? byCategory.entries.toList()
        : List.generate(5, (i) => MapEntry(_fixedLabels[i], _fixedPcts[i] * (totalExpense > 0 ? totalExpense : 140370)));
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(children: [
        Row(children: [
          // Donut
          SizedBox(
            width: 140, height: 140,
            child: Stack(alignment: Alignment.center, children: [
              PieChart(PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (ev, resp) {
                    if (ev.isInterestedForInteractions && resp?.touchedSection != null) {
                      onTouch(resp!.touchedSection!.touchedSectionIndex);
                    } else { onTouch(-1); }
                  },
                ),
                sections: entries.asMap().entries.map((e) {
                  final i = e.key; final isTouched = i == touched;
                  return PieChartSectionData(
                    value: e.value.value, color: _colors[i % _colors.length],
                    radius: isTouched ? 52 : 44, title: '',
                  );
                }).toList(),
                centerSpaceRadius: 36, sectionsSpace: 3,
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('PKR', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                Text(Formatters.currencyCompact(total),
                    style: const TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            child: Column(children: entries.asMap().entries.map((e) {
              final i = e.key; final pct = total > 0 ? e.value.value / total * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 10, height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _colors[i % _colors.length])),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value.key,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
                  Text('${pct.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              );
            }).toList()),
          ),
        ]),
      ]),
    );
  }
}

// ── Monthly Trend Bar Chart ───────────────────────────────────────────────────
class _MonthlyTrendCard extends StatelessWidget {
  final List months;
  final int? selectedId;
  final double income, expense;

  const _MonthlyTrendCard({
    required this.months, required this.selectedId,
    required this.income, required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return Container(height: 180, decoration: BoxDecoration(color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bgCardBorder)),
          child: const Center(child: Text('No data', style: TextStyle(color: AppColors.textSecondary))));
    }

    // Build bar groups — selected month uses real data, others demo
    final groups = months.asMap().entries.map((e) {
      final i   = e.key;
      final m   = e.value;
      final sel = m.id == selectedId;
      final inc = sel ? income : (i * 15000.0 + 40000);
      final exp = sel ? expense : (i * 8000.0  + 25000);
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: inc, color: AppColors.accentBlue, width: 10,
            borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: exp, color: AppColors.purple.withOpacity(0.7), width: 10,
            borderRadius: BorderRadius.circular(4)),
      ], barsSpace: 3);
    }).toList();

    final maxY = [income, expense, ...months.asMap().entries.map((e) {
      final i = e.key; return i * 15000.0 + 40000;
    })].reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 180,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: AppColors.bgCardLight,
                getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                  Formatters.currencyCompact(rod.toY),
                  const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final i = val.toInt();
                  if (i < 0 || i >= months.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(months[i].name.substring(0, 3),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  );
                },
              )),
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 52,
                getTitlesWidget: (val, meta) => Text(
                  Formatters.currencyCompact(val),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                ),
              )),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.bgCardBorder, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: groups,
          )),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Legend(color: AppColors.accentBlue, label: 'Income'),
          const SizedBox(width: 20),
          _Legend(color: AppColors.purple, label: 'Expenses'),
        ]),
      ]),
    );
  }
}

// ── Income vs Expense Comparison ──────────────────────────────────────────────
class _IncomeExpenseCard extends StatelessWidget {
  final double income, expense, saving;
  const _IncomeExpenseCard({required this.income, required this.expense, required this.saving});

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final incPct = total > 0 ? income / total : 0.5;
    final expPct = total > 0 ? expense / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(children: [
        // Stacked progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(children: [
              Flexible(
                flex: (incPct * 100).toInt(),
                child: Container(color: AppColors.green),
              ),
              Flexible(
                flex: (expPct * 100).toInt(),
                child: Container(color: AppColors.red),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _CompStat(
            label: 'Income', value: income,
            color: AppColors.green, pct: incPct,
          )),
          Container(width: 1, height: 48, color: AppColors.bgCardBorder),
          Expanded(child: _CompStat(
            label: 'Expense', value: expense,
            color: AppColors.red, pct: expPct,
          )),
          Container(width: 1, height: 48, color: AppColors.bgCardBorder),
          Expanded(child: _CompStat(
            label: 'Savings', value: saving,
            color: saving >= 0 ? AppColors.green : AppColors.red,
            pct: income > 0 ? saving / income : 0,
          )),
        ]),
        const SizedBox(height: 16),
        // Savings insight
        Container(
          width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.green.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.tips_and_updates_rounded, color: AppColors.green, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              income > 0
                  ? saving / income >= 0.2
                      ? '🎉 Great! Saving ${(saving/income*100).toStringAsFixed(1)}% of income.'
                      : saving / income >= 0.1
                          ? '👍 On track. Aim for 20% savings rate.'
                          : '⚠️ Try to reduce expenses for better savings.'
                  : 'Add income to see savings insights.',
              style: const TextStyle(color: AppColors.green, fontSize: 12),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _CompStat extends StatelessWidget {
  final String label; final double value, pct; final Color color;
  const _CompStat({required this.label, required this.value, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
    const SizedBox(height: 4),
    Text(Formatters.currencyCompact(value),
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    Text('${(pct.abs() * 100).toStringAsFixed(0)}%',
        style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
  ]);
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
  ]);
}
