import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/month_provider.dart';
import '../../providers/income_provider.dart';
import '../../../data/models/income_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});
  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Salary', 'OT', 'Extra', 'Others'];

  @override
  Widget build(BuildContext context) {
    return Consumer2<MonthProvider, IncomeProvider>(
      builder: (_, mp, ip, __) {
        final month = mp.selectedMonth;
        final filtered = _filter == 'All'
            ? ip.incomes
            : ip.incomes.where((i) {
                if (_filter == 'Salary') return i.category == 'Salary';
                if (_filter == 'OT')     return i.category == 'OT';
                if (_filter == 'Extra')  return i.category == 'Extra Income';
                return !['Salary','OT','Extra Income'].contains(i.category);
              }).toList();

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgDark,
            title: const Text('Income'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                onPressed: () => _showForm(context, month?.id, ip),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ip.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
              : CustomScrollView(
                  slivers: [
                    // Total + Mini Chart
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: _IncomeSummaryCard(
                          total: ip.totalIncome,
                          incomes: ip.incomes,
                        ),
                      ),
                    ),
                    // Filter chips
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters.map((f) {
                              final sel = _filter == f;
                              return GestureDetector(
                                onTap: () => setState(() => _filter = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.accentBlue : AppColors.bgCardLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: sel ? AppColors.accentBlue : AppColors.bgCardBorder,
                                    ),
                                  ),
                                  child: Text(f,
                                      style: TextStyle(
                                        color: sel ? Colors.white : AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                      )),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // Income list
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      sliver: filtered.isEmpty
                          ? SliverToBoxAdapter(child: _emptyState())
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) => _IncomeListItem(
                                  income: filtered[i],
                                  onEdit: () => _showForm(context, month?.id, ip, existing: filtered[i]),
                                  onDelete: () => _delete(context, filtered[i].id!, ip),
                                ),
                                childCount: filtered.length,
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _emptyState() => Container(
    margin: const EdgeInsets.only(top: 40),
    child: const Center(
      child: Column(children: [
        Icon(Icons.trending_up_outlined, size: 60, color: AppColors.bgCardBorder),
        SizedBox(height: 12),
        Text('No income records', style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 6),
        Text('Tap + to add income', style: TextStyle(color: AppColors.accentBlue, fontSize: 13)),
      ]),
    ),
  );

  Future<void> _showForm(BuildContext ctx, int? monthId, IncomeProvider ip, {IncomeModel? existing}) async {
    if (monthId == null) return;
    await showModalBottomSheet(
      context: ctx, isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _IncomeFormSheet(monthId: monthId, existing: existing, onSave: (income) async {
        if (existing != null) await ip.updateIncome(income);
        else await ip.addIncome(income);
      }),
    );
  }

  Future<void> _delete(BuildContext ctx, int id, IncomeProvider ip) async {
    final ok = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppColors.bgCard,
      title: const Text('Delete Income', style: TextStyle(color: Colors.white)),
      content: const Text('Delete this income entry?', style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red))),
      ],
    ));
    if (ok == true) await ip.deleteIncome(id);
  }
}

// ── Income Summary Card with mini sparkline ───────────────────────────────────
class _IncomeSummaryCard extends StatelessWidget {
  final double total;
  final List<IncomeModel> incomes;
  const _IncomeSummaryCard({required this.total, required this.incomes});

  @override
  Widget build(BuildContext context) {
    // Build sparkline data
    final spots = incomes.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value.amount)).toList();
    if (spots.isEmpty) spots.add(const FlSpot(0, 0));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Income', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bgCardBorder),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('This Month', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 14),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Text(Formatters.currency(total),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: LineChart(LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.green,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (spot, pct, bar, i) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.green,
                  strokeWidth: 2,
                  strokeColor: AppColors.bgCard,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppColors.green.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
            )],
            minX: 0, maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
          )),
        ),
      ]),
    );
  }
}

// ── Income List Item ──────────────────────────────────────────────────────────
class _IncomeListItem extends StatelessWidget {
  final IncomeModel income;
  final VoidCallback onEdit, onDelete;
  const _IncomeListItem({required this.income, required this.onEdit, required this.onDelete});

  static const _catColors = {
    'Salary': AppColors.accentBlue,
    'OT': AppColors.purple,
    'Extra Income': AppColors.green,
    'Freelance': AppColors.yellow,
  };
  static const _catIcons = {
    'Salary': Icons.work_rounded,
    'OT': Icons.access_time_rounded,
    'Extra Income': Icons.star_rounded,
    'Freelance': Icons.laptop_rounded,
  };
  static const _catLabels = {
    'Salary': 'Salary',
    'OT': 'OT',
    'Extra Income': 'Freelance',
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[income.category] ?? AppColors.green;
    final icon  = _catIcons[income.category]  ?? Icons.attach_money_rounded;
    final label = _catLabels[income.category] ?? income.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(income.category,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(
          income.date,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(Formatters.currency(income.amount),
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ]),
        onLongPress: () {
          showModalBottomSheet(context: context, backgroundColor: AppColors.bgCard,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(leading: const Icon(Icons.edit_rounded, color: AppColors.accentBlue),
                    title: const Text('Edit', style: TextStyle(color: Colors.white)),
                    onTap: () { Navigator.pop(context); onEdit(); }),
                ListTile(leading: const Icon(Icons.delete_rounded, color: AppColors.red),
                    title: const Text('Delete', style: TextStyle(color: AppColors.red)),
                    onTap: () { Navigator.pop(context); onDelete(); }),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Income Form Sheet ─────────────────────────────────────────────────────────
class _IncomeFormSheet extends StatefulWidget {
  final int monthId;
  final IncomeModel? existing;
  final void Function(IncomeModel) onSave;
  const _IncomeFormSheet({required this.monthId, this.existing, required this.onSave});

  @override
  State<_IncomeFormSheet> createState() => _IncomeFormSheetState();
}

class _IncomeFormSheetState extends State<_IncomeFormSheet> {
  late String _cat;
  final _amtCtrl = TextEditingController();
  final _remCtrl = TextEditingController();
  final _cusCtrl = TextEditingController();
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _cat = AppConstants.defaultIncomeCategories.contains(e.category) ? e.category : 'Custom';
      _custom = !AppConstants.defaultIncomeCategories.contains(e.category);
      if (_custom) _cusCtrl.text = e.category;
      _amtCtrl.text = e.amount.toString();
      _remCtrl.text = e.remarks ?? '';
    } else { _cat = AppConstants.defaultIncomeCategories.first; }
  }

  @override
  void dispose() { _amtCtrl.dispose(); _remCtrl.dispose(); _cusCtrl.dispose(); super.dispose(); }

  void _save() {
    final amt = double.tryParse(_amtCtrl.text.trim());
    if (amt == null || amt <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount'))); return; }
    final cat = _custom ? _cusCtrl.text.trim() : _cat;
    if (cat.isEmpty) return;
    final now = DateTime.now().toIso8601String();
    widget.onSave(IncomeModel(
      id: widget.existing?.id, monthId: widget.monthId, category: cat, amount: amt,
      remarks: _remCtrl.text.trim().isEmpty ? null : _remCtrl.text.trim(),
      date: now.substring(0, 10), createdAt: widget.existing?.createdAt ?? now,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.existing != null ? 'Edit Income' : 'Add Income',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _custom ? 'Custom' : _cat,
          dropdownColor: AppColors.bgCardLight,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [...AppConstants.defaultIncomeCategories.map((c) =>
              DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))),
            const DropdownMenuItem(value: 'Custom', child: Text('Custom...', style: TextStyle(color: Colors.white)))],
          onChanged: (v) => setState(() { _custom = v == 'Custom'; _cat = v!; }),
        ),
        if (_custom) ...[const SizedBox(height: 12),
          TextField(controller: _cusCtrl, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Custom Category'))],
        const SizedBox(height: 12),
        TextField(controller: _amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Amount (PKR)', prefixText: '₨ ')),
        const SizedBox(height: 12),
        TextField(controller: _remCtrl, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Remarks (optional)')),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: _save,
                child: Text(widget.existing != null ? 'Update Income' : 'Add Income'))),
      ]),
    );
  }
}
