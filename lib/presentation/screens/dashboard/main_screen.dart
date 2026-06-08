import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../income/income_screen.dart';
import '../expense/expense_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/month_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMonth());
  }

  Future<void> _loadMonth() async {
    final mp = context.read<MonthProvider>();
    if (mp.selectedMonth != null) {
      final id = mp.selectedMonth!.id!;
      await context.read<IncomeProvider>().loadForMonth(id);
      await context.read<ExpenseProvider>().loadForMonth(id);
    }
  }

  final _screens = const [
    DashboardScreen(),
    IncomeScreen(),
    ExpenseScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  final _labels = ['Dashboard', 'Income', 'Expenses', 'Analytics', 'Settings'];
  final _icons  = [
    Icons.grid_view_rounded,
    Icons.trending_up_rounded,
    Icons.receipt_long_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBg,
          border: const Border(top: BorderSide(color: AppColors.bgCardBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final sel = _index == i;
                return GestureDetector(
                  onTap: () => setState(() => _index = i),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 64,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.accentBlue.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _icons[i],
                              color: sel ? AppColors.accentBlue : AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              color: sel ? AppColors.accentBlue : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
