import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/month_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/loan_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<MonthProvider, IncomeProvider, ExpenseProvider, LoanProvider>(
      builder: (_, mp, ip, ep, lp, __) {
        final month = mp.selectedMonth;
        final income  = ip.totalIncome;
        final expense = ep.totalAllExpenses;
        final saving  = income - expense;
        final savPct  = income > 0 ? saving / income * 100 : 0.0;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.accentBlue,
              onRefresh: () async {
                if (month != null) {
                  await ip.loadForMonth(month.id!);
                  await ep.loadForMonth(month.id!);
                }
              },
              child: CustomScrollView(
                slivers: [
                  // ── App Bar ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Good Morning,',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Row(children: [
                              const Text('FasXeeH ',
                                  style: TextStyle(color: Colors.white, fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                              const Text('👋',style: TextStyle(fontSize: 20)),
                            ]),
                          ]),
                          const Spacer(),
                          // Month dropdown
                          GestureDetector(
                            onTap: () => _showMonthPicker(context, mp),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.bgCardLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.bgCardBorder),
                              ),
                              child: Row(children: [
                                Text(month?.displayName ?? '—',
                                    style: const TextStyle(color: Colors.white, fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 6),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textSecondary, size: 18),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _AvatarButton(onTap: () {}),
                        ],
                      ),
                    ),
                  ),

                  // ── Total Balance Hero Card ───────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _BalanceCard(
                        saving: saving, income: income, savPct: savPct,
                      ),
                    ),
                  ),

                  // ── 4 Stat Cards ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(children: [
                        Expanded(child: _StatCard(
                          label: 'Total Income',
                          value: Formatters.currencyCompact(income),
                          icon: Icons.north_east_rounded,
                          color: AppColors.green,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          label: 'Total Expenses',
                          value: Formatters.currencyCompact(expense),
                          icon: Icons.south_west_rounded,
                          color: AppColors.red,
                        )),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(children: [
                        Expanded(child: _StatCard(
                          label: 'Net Savings',
                          value: Formatters.currencyCompact(saving),
                          icon: Icons.savings_rounded,
                          color: AppColors.accentBlue,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(
                          label: 'Savings %',
                          value: '${savPct.toStringAsFixed(1)}%',
                          icon: Icons.percent_rounded,
                          color: AppColors.yellow,
                        )),
                      ]),
                    ),
                  ),

                  // ── Quick Actions ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _QuickActions(mp: mp, ip: ip, ep: ep),
                    ),
                  ),

                  // ── Overview Donut ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _OverviewCard(
                        income: income,
                        expense: expense,
                        saving: saving,
                        byCategory: ep.byCategory,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context, MonthProvider mp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MonthPickerSheet(mp: mp),
    );
  }
}

// ── Balance Hero Card ────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final double saving, income, savPct;
  const _BalanceCard({required this.saving, required this.income, required this.savPct});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A8F), Color(0xFF0E1F5B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.2),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                Formatters.currency(saving),
                style: const TextStyle(color: Colors.white, fontSize: 28,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.arrow_upward_rounded,
                        color: AppColors.green, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '${savPct.toStringAsFixed(1)}% vs May',
                      style: const TextStyle(color: AppColors.green, fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
              ]),
            ]),
          ),
          // Wallet illustration
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder, width: 1),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        ])),
      ]),
    );
  }
}

// ── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final MonthProvider mp;
  final IncomeProvider ip;
  final ExpenseProvider ep;
  const _QuickActions({required this.mp, required this.ip, required this.ep});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.add_circle_rounded,    'label': 'Add Income',      'color': AppColors.green},
      {'icon': Icons.remove_circle_rounded, 'label': 'Add Expense',     'color': AppColors.red},
      {'icon': Icons.account_balance_rounded,'label': 'Add Loan',       'color': AppColors.purple},
      {'icon': Icons.description_rounded,   'label': 'Generate\nReport','color': AppColors.yellow},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Quick Actions',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          TextButton(
            onPressed: () {},
            child: const Text('View All',
                style: TextStyle(color: AppColors.accentBlue, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((a) {
            final color = a['color'] as Color;
            return GestureDetector(
              onTap: () {},
              child: Column(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(a['icon'] as IconData, color: color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
                  style: const TextStyle(color: AppColors.textSecondary,
                      fontSize: 11, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ]),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Overview Donut Chart ─────────────────────────────────────────────────────
class _OverviewCard extends StatefulWidget {
  final double income, expense, saving;
  final Map<String, double> byCategory;
  const _OverviewCard({required this.income, required this.expense,
      required this.saving, required this.byCategory});

  @override
  State<_OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<_OverviewCard> {
  int _touched = -1;

  static const _labels  = ['Needs',   'Wants',   'Savings', 'Investments'];
  static const _colors  = [AppColors.accentBlue, AppColors.yellow, AppColors.green, AppColors.purple];
  static const _pcts    = [0.45, 0.25, 0.20, 0.10];

  @override
  Widget build(BuildContext context) {
    final total = widget.expense > 0 ? widget.expense : 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Overview',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.bgCardBorder),
              ),
              child: const Row(children: [
                Text('This Month', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 16),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut
              SizedBox(
                width: 110, height: 110,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, resp) {
                        if (event.isInterestedForInteractions && resp?.touchedSection != null) {
                          setState(() => _touched = resp!.touchedSection!.touchedSectionIndex);
                        } else {
                          setState(() => _touched = -1);
                        }
                      },
                    ),
                    sections: List.generate(4, (i) {
                      final isTouched = i == _touched;
                      return PieChartSectionData(
                        value: _pcts[i] * total,
                        color: _colors[i],
                        radius: isTouched ? 46 : 38,
                        title: '',
                        borderSide: isTouched
                            ? BorderSide(color: _colors[i], width: 2)
                            : BorderSide.none,
                      );
                    }),
                    centerSpaceRadius: 28,
                    sectionsSpace: 3,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  children: List.generate(4, (i) {
                    final amt = _pcts[i] * widget.expense;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Container(width: 10, height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: _colors[i])),
                        const SizedBox(width: 8),
                        Text(_labels[i],
                            style: const TextStyle(color: AppColors.textSecondary,
                                fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('${(_pcts[i]*100).toInt()}%',
                            style: const TextStyle(color: AppColors.textSecondary,
                                fontSize: 11)),
                        const Spacer(),
                        Text(Formatters.currencyCompact(amt),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar button ────────────────────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AvatarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.accentBlueDark],
            ),
            border: Border.all(color: AppColors.accentBlue.withOpacity(0.5), width: 2),
          ),
          child: const Center(
            child: Text('F', style: TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
        Positioned(
          right: 0, bottom: 0,
          child: Container(
            width: 12, height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.green,
              border: Border.fromBorderSide(
                  BorderSide(color: AppColors.bgDark, width: 2)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Month Picker Sheet ────────────────────────────────────────────────────────
class _MonthPickerSheet extends StatelessWidget {
  final MonthProvider mp;
  const _MonthPickerSheet({required this.mp});

  @override
  Widget build(BuildContext context) {
    final available = mp.getAvailableMonthsToAdd();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Select Month',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...mp.months.map((m) {
          final sel = mp.selectedMonth?.id == m.id;
          return ListTile(
            title: Text(m.displayName,
                style: TextStyle(color: sel ? AppColors.accentBlue : Colors.white)),
            trailing: sel ? const Icon(Icons.check_rounded, color: AppColors.accentBlue) : null,
            onTap: () {
              mp.selectMonth(m);
              Navigator.pop(context);
              final ip = context.read<IncomeProvider>();
              final ep = context.read<ExpenseProvider>();
              ip.loadForMonth(m.id!);
              ep.loadForMonth(m.id!);
            },
          );
        }),
        if (available.isNotEmpty) ...[
          const Divider(color: AppColors.bgCardBorder),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accentBlue),
            title: const Text('Add New Month',
                style: TextStyle(color: AppColors.accentBlue)),
            onTap: () {
              Navigator.pop(context);
              _showAddDialog(context);
            },
          ),
        ],
        const SizedBox(height: 16),
      ]),
    );
  }

  void _showAddDialog(BuildContext context) {
    final available = mp.getAvailableMonthsToAdd();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Add Month',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...available.take(12).map((item) => ListTile(
            title: Text('${item['name']} ${item['year']}',
                style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.add_rounded, color: AppColors.accentBlue),
            onTap: () async {
              Navigator.pop(context);
              await mp.addMonth(item['name'], item['year'], item['month_number']);
            },
          )),
        ],
      ),
    );
  }
}
