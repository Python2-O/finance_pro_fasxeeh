import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/month_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/bill_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Needs', 'Wants', 'Bills', 'Other'];

  // category → filter group
  static const _catGroup = {
    'Food': 'Needs', 'Healthcare': 'Needs',
    'Transport': 'Wants', 'Entertainment': 'Wants', 'Shopping': 'Wants',
    'Grocery': 'Bills', 'Electricity': 'Bills', 'Wifi': 'Bills',
    'Drinking Water': 'Bills', 'Mobile Recharge': 'Bills', 'Loan Repayment': 'Bills',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer2<MonthProvider, ExpenseProvider>(
      builder: (_, mp, ep, __) {
        final month = mp.selectedMonth;

        // Build unified list
        final allItems = <_ExpItem>[
          ...ep.expenses.map((e) => _ExpItem(
            title: e.subCategory ?? e.category,
            category: e.category,
            amount: e.amount,
            subtitle: e.remarks?.isNotEmpty == true ? e.remarks! : 'Day ${e.day}',
            tag: _catGroup[e.category] ?? 'Other',
            id: e.id!, isBill: false, model: e,
          )),
          ...ep.bills.map((b) => _ExpItem(
            title: b.category, category: b.category,
            amount: b.amount,
            subtitle: b.remarks ?? 'Monthly bill',
            tag: 'Bills',
            id: b.id!, isBill: true, billModel: b,
          )),
        ]..sort((a, b) => b.amount.compareTo(a.amount));

        final filtered = _filter == 'All'
            ? allItems
            : allItems.where((e) => e.tag == _filter).toList();

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgDark,
            title: const Text('Expenses'), centerTitle: true,
            actions: [
              IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.accentBlue, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                onPressed: () => _showMenu(context, month?.id, ep),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ep.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
              : CustomScrollView(slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: _ExpenseSummaryCard(
                        total: ep.totalAllExpenses,
                        expenses: ep.expenses,
                      ),
                    ),
                  ),
                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _filters.map((f) {
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
                                border: Border.all(color: sel ? AppColors.accentBlue : AppColors.bgCardBorder),
                              ),
                              child: Text(f, style: TextStyle(
                                color: sel ? Colors.white : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                              )),
                            ),
                          );
                        }).toList()),
                      ),
                    ),
                  ),
                  // Expense list
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: filtered.isEmpty
                        ? SliverToBoxAdapter(child: _emptyState())
                        : SliverList(delegate: SliverChildBuilderDelegate(
                            (_, i) => _ExpItemTile(
                              item: filtered[i],
                              onEdit: () => filtered[i].isBill
                                  ? _showBillForm(context, month?.id, ep, existing: filtered[i].billModel)
                                  : _showExpenseForm(context, month?.id, ep, existing: filtered[i].model),
                              onDelete: () => filtered[i].isBill
                                  ? ep.deleteBill(filtered[i].id)
                                  : ep.deleteExpense(filtered[i].id),
                            ),
                            childCount: filtered.length,
                          )),
                  ),
                  // View All footer
                  if (allItems.length > 5)
                    SliverToBoxAdapter(
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Text('View All Expenses',
                              style: TextStyle(color: AppColors.accentBlue)),
                          label: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.accentBlue, size: 18),
                        ),
                      ),
                    ),
                ]),
        );
      },
    );
  }

  Widget _emptyState() => const Center(
    child: Padding(
      padding: EdgeInsets.only(top: 40),
      child: Column(children: [
        Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.bgCardBorder),
        SizedBox(height: 12),
        Text('No expenses yet', style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 6),
        Text('Tap + to add expense', style: TextStyle(color: AppColors.accentBlue, fontSize: 13)),
      ]),
    ),
  );

  void _showMenu(BuildContext ctx, int? mid, ExpenseProvider ep) {
    showModalBottomSheet(
      context: ctx, backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.red)),
            title: const Text('Daily Expense', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(ctx); _showExpenseForm(ctx, mid, ep); },
          ),
          ListTile(
            leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.accentBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_rounded, color: AppColors.accentBlue)),
            title: const Text('Monthly Bill', style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(ctx); _showBillForm(ctx, mid, ep); },
          ),
        ]),
      ),
    );
  }

  Future<void> _showExpenseForm(BuildContext ctx, int? mid, ExpenseProvider ep, {ExpenseModel? existing}) async {
    if (mid == null) return;
    await showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ExpenseFormSheet(monthId: mid, existing: existing, onSave: (e) async {
        if (existing != null) await ep.updateExpense(e); else await ep.addExpense(e);
      }),
    );
  }

  Future<void> _showBillForm(BuildContext ctx, int? mid, ExpenseProvider ep, {BillModel? existing}) async {
    if (mid == null) return;
    await showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BillFormSheet(monthId: mid, existing: existing, onSave: (b) async {
        if (existing != null) await ep.updateBill(b); else await ep.addBill(b);
      }),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _ExpItem {
  final String title, category, subtitle, tag;
  final double amount;
  final int id;
  final bool isBill;
  final ExpenseModel? model;
  final BillModel? billModel;
  const _ExpItem({required this.title, required this.category, required this.amount,
      required this.subtitle, required this.tag, required this.id, required this.isBill,
      this.model, this.billModel});
}

// ── Expense summary card ──────────────────────────────────────────────────────
class _ExpenseSummaryCard extends StatelessWidget {
  final double total;
  final List<ExpenseModel> expenses;
  const _ExpenseSummaryCard({required this.total, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final spots = expenses.asMap().entries.map((e) =>
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
          const Text('Total Expenses', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight, borderRadius: BorderRadius.circular(8),
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
        SizedBox(height: 80,
          child: LineChart(LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: spots, isCurved: true, color: AppColors.red, barWidth: 2.5,
              dotData: FlDotData(getDotPainter: (_, __, ___, ____) =>
                  FlDotCirclePainter(radius: 4, color: AppColors.red, strokeWidth: 2, strokeColor: AppColors.bgCard)),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                colors: [AppColors.red.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              )),
            )],
            minX: 0, maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
          )),
        ),
      ]),
    );
  }
}

// ── Expense item tile ─────────────────────────────────────────────────────────
class _ExpItemTile extends StatelessWidget {
  final _ExpItem item;
  final VoidCallback onEdit, onDelete;
  const _ExpItemTile({required this.item, required this.onEdit, required this.onDelete});

  static const _catColors = {
    'Food': AppColors.yellow, 'Transport': AppColors.red,
    'Electricity': AppColors.accentBlue, 'Mobile Recharge': AppColors.accentBlue,
    'Shopping': AppColors.purple, 'Grocery': AppColors.green,
    'Miscellaneous': AppColors.textSecondary,
  };
  static const _catIcons = {
    'Food': Icons.restaurant_rounded, 'Transport': Icons.directions_car_rounded,
    'Electricity': Icons.bolt_rounded, 'Mobile Recharge': Icons.phone_android_rounded,
    'Shopping': Icons.shopping_bag_rounded, 'Grocery': Icons.shopping_cart_rounded,
    'Miscellaneous': Icons.category_rounded, 'Healthcare': Icons.local_hospital_rounded,
    'Wifi': Icons.wifi_rounded, 'Entertainment': Icons.movie_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[item.category] ?? AppColors.textSecondary;
    final icon  = _catIcons[item.category]  ?? Icons.receipt_rounded;
    final tagColor = item.tag == 'Bills' ? AppColors.accentBlue
        : item.tag == 'Needs' ? AppColors.red : AppColors.yellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(item.title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(item.subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(Formatters.currency(item.amount),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(item.tag,
                style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.w500)),
          ),
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

// ── Expense Form ──────────────────────────────────────────────────────────────
class _ExpenseFormSheet extends StatefulWidget {
  final int monthId; final ExpenseModel? existing;
  final void Function(ExpenseModel) onSave;
  const _ExpenseFormSheet({required this.monthId, this.existing, required this.onSave});
  @override State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}
class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  late String _cat; final _amtCtrl = TextEditingController();
  final _dayCtrl = TextEditingController(); final _remCtrl = TextEditingController();
  final _cusCtrl = TextEditingController(); bool _custom = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _cat = AppConstants.defaultExpenseCategories.contains(e.category) ? e.category : 'Custom';
      _custom = !AppConstants.defaultExpenseCategories.contains(e.category);
      if (_custom) _cusCtrl.text = e.category;
      _amtCtrl.text = e.amount.toString(); _dayCtrl.text = e.day.toString();
      _remCtrl.text = e.remarks ?? '';
    } else { _cat = AppConstants.defaultExpenseCategories.first; _dayCtrl.text = DateTime.now().day.toString(); }
  }

  @override void dispose() { _amtCtrl.dispose(); _dayCtrl.dispose(); _remCtrl.dispose(); _cusCtrl.dispose(); super.dispose(); }

  void _save() {
    final amt = double.tryParse(_amtCtrl.text.trim()); final day = int.tryParse(_dayCtrl.text.trim()) ?? DateTime.now().day;
    if (amt == null || amt <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount'))); return; }
    final cat = _custom ? _cusCtrl.text.trim() : _cat; final now = DateTime.now().toIso8601String();
    widget.onSave(ExpenseModel(id: widget.existing?.id, monthId: widget.monthId, category: cat,
        subCategory: cat, amount: amt, day: day, date: now.substring(0, 10),
        remarks: _remCtrl.text.trim().isEmpty ? null : _remCtrl.text.trim(),
        createdAt: widget.existing?.createdAt ?? now));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.existing != null ? 'Edit Expense' : 'Add Daily Expense',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _custom ? 'Custom' : _cat, dropdownColor: AppColors.bgCardLight,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [...AppConstants.defaultExpenseCategories.map((c) =>
              DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))),
            const DropdownMenuItem(value: 'Custom', child: Text('Custom...', style: TextStyle(color: Colors.white)))],
          onChanged: (v) => setState(() { _custom = v == 'Custom'; _cat = v!; }),
        ),
        if (_custom) ...[const SizedBox(height: 12),
          TextField(controller: _cusCtrl, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Custom Category'))],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Amount (PKR)', prefixText: '₨ '))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _dayCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Day of Month'))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _remCtrl, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Remarks (optional)')),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save,
            child: Text(widget.existing != null ? 'Update' : 'Add Expense'))),
      ]),
    );
  }
}

// ── Bill Form ─────────────────────────────────────────────────────────────────
class _BillFormSheet extends StatefulWidget {
  final int monthId; final BillModel? existing;
  final void Function(BillModel) onSave;
  const _BillFormSheet({required this.monthId, this.existing, required this.onSave});
  @override State<_BillFormSheet> createState() => _BillFormSheetState();
}
class _BillFormSheetState extends State<_BillFormSheet> {
  late String _cat; final _amtCtrl = TextEditingController(); final _remCtrl = TextEditingController();
  final _cusCtrl = TextEditingController(); bool _custom = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final b = widget.existing!;
      _cat = AppConstants.defaultBillCategories.contains(b.category) ? b.category : 'Custom';
      _custom = !AppConstants.defaultBillCategories.contains(b.category);
      if (_custom) _cusCtrl.text = b.category;
      _amtCtrl.text = b.amount.toString(); _remCtrl.text = b.remarks ?? '';
    } else { _cat = AppConstants.defaultBillCategories.first; }
  }

  @override void dispose() { _amtCtrl.dispose(); _remCtrl.dispose(); _cusCtrl.dispose(); super.dispose(); }

  void _save() {
    final amt = double.tryParse(_amtCtrl.text.trim());
    if (amt == null || amt <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount'))); return; }
    final cat = _custom ? _cusCtrl.text.trim() : _cat; final now = DateTime.now().toIso8601String();
    widget.onSave(BillModel(id: widget.existing?.id, monthId: widget.monthId, category: cat, amount: amt,
        remarks: _remCtrl.text.trim().isEmpty ? null : _remCtrl.text.trim(),
        createdAt: widget.existing?.createdAt ?? now));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.existing != null ? 'Edit Bill' : 'Add Monthly Bill',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context)),
        ]),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _custom ? 'Custom' : _cat, dropdownColor: AppColors.bgCardLight,
          decoration: const InputDecoration(labelText: 'Bill Category'),
          items: [...AppConstants.defaultBillCategories.map((c) =>
              DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))),
            const DropdownMenuItem(value: 'Custom', child: Text('Custom...', style: TextStyle(color: Colors.white)))],
          onChanged: (v) => setState(() { _custom = v == 'Custom'; _cat = v!; }),
        ),
        if (_custom) ...[const SizedBox(height: 12),
          TextField(controller: _cusCtrl, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Custom Bill Name'))],
        const SizedBox(height: 12),
        TextField(controller: _amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Amount (PKR)', prefixText: '₨ ')),
        const SizedBox(height: 12),
        TextField(controller: _remCtrl, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Remarks (optional)')),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save,
            child: Text(widget.existing != null ? 'Update Bill' : 'Add Bill'))),
      ]),
    );
  }
}
