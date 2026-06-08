import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/month_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/loan_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _tab = 'Summary';
  final _tabs = ['Summary', 'Income', 'Expenses', 'Loans'];

  @override
  Widget build(BuildContext context) {
    return Consumer4<MonthProvider, IncomeProvider, ExpenseProvider, LoanProvider>(
      builder: (_, mp, ip, ep, lp, __) {
        final month   = mp.selectedMonth;
        final income  = ip.totalIncome;
        final expense = ep.totalAllExpenses;
        final saving  = income - expense;
        final savPct  = income > 0 ? saving / income * 100 : 0.0;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgDark,
            leading: const Icon(Icons.menu_rounded, color: AppColors.textSecondary),
            title: const Text('Reports'), centerTitle: true,
          ),
          body: Column(children: [
            // Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _TabBar(selected: _tab, tabs: _tabs, onChanged: (t) => setState(() => _tab = t)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_tab == 'Summary') _SummaryTab(
                    monthName: month?.displayName ?? '—',
                    income: income, expense: expense,
                    saving: saving, savPct: savPct,
                  ),
                  if (_tab == 'Income')   _IncomeTab(ip: ip),
                  if (_tab == 'Expenses') _ExpensesTab(ep: ep),
                  if (_tab == 'Loans')    _LoansTab(lp: lp),
                ]),
              ),
            ),
            // Export buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(top: BorderSide(color: AppColors.bgCardBorder)),
              ),
              child: Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportPDF(context, month?.displayName ?? '—',
                        income, expense, saving, savPct, ip, ep, lp),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('Export PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportExcel(context, month?.displayName ?? '—', ip, ep),
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('Export Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }

  Future<void> _exportPDF(BuildContext context, String monthName,
      double income, double expense, double saving, double savPct,
      IncomeProvider ip, ExpenseProvider ep, LoanProvider lp) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Finance Pro – FasXeeH',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Monthly Report · $monthName',
                  style: const pw.TextStyle(color: PdfColors.white70, fontSize: 14)),
              pw.Text('Generated: ${Formatters.date(DateTime.now())}',
                  style: const pw.TextStyle(color: PdfColors.white54, fontSize: 11)),
            ]),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfHeader(['Item', 'Amount']),
              _pdfRow(['Total Income',    Formatters.currency(income)]),
              _pdfRow(['Total Expenses',  Formatters.currency(expense)]),
              _pdfRow(['Net Savings',     Formatters.currency(saving)]),
              _pdfRow(['Savings Rate',    '${savPct.toStringAsFixed(1)}%']),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Income', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfHeader(['Category', 'Amount', 'Remarks']),
              ...ip.incomes.map((i) => _pdfRow([i.category, Formatters.currency(i.amount), i.remarks ?? ''])),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Expenses', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfHeader(['Category', 'Amount']),
              ...ep.byCategory.entries.map((e) => _pdfRow([e.key, Formatters.currency(e.value)])),
              _pdfRow(['Bills Total', Formatters.currency(ep.totalBills)]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Loans', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _pdfHeader(['Type', 'Person', 'Original', 'Paid', 'Pending']),
              ...lp.borrowedLoans.map((l) => _pdfRow([
                'Borrowed', l.person, Formatters.currency(l.originalAmount),
                Formatters.currency(l.paidOrReceived), Formatters.currency(l.pending),
              ])),
              ...lp.lentLoans.map((l) => _pdfRow([
                'Lent', l.person, Formatters.currency(l.originalAmount),
                Formatters.currency(l.paidOrReceived), Formatters.currency(l.pending),
              ])),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Center(child: pw.Text('Finance Pro – FasXeeH · Track · Save · Grow',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10))),
        ],
      ));

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/FinancePro_${monthName.replaceAll(' ', '_')}.pdf');
      await file.writeAsBytes(await pdf.save());
      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Finance Pro Report – $monthName');
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _exportExcel(BuildContext context, String monthName,
      IncomeProvider ip, ExpenseProvider ep) async {
    try {
      final dir  = await getTemporaryDirectory();
      final csv  = StringBuffer();
      csv.writeln('Finance Pro – FasXeeH — $monthName');
      csv.writeln('');
      csv.writeln('INCOME');
      csv.writeln('Category,Amount,Remarks');
      for (final i in ip.incomes) csv.writeln('${i.category},${i.amount},${i.remarks ?? ''}');
      csv.writeln('');
      csv.writeln('EXPENSES BY CATEGORY');
      csv.writeln('Category,Amount');
      for (final e in ep.byCategory.entries) csv.writeln('${e.key},${e.value}');
      csv.writeln('');
      csv.writeln('BILLS');
      csv.writeln('Category,Amount');
      for (final b in ep.bills) csv.writeln('${b.category},${b.amount}');

      final file = File('${dir.path}/FinancePro_${monthName.replaceAll(' ', '_')}.csv');
      await file.writeAsString(csv.toString());
      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Finance Pro Data – $monthName');
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  pw.TableRow _pdfHeader(List<String> cells) => pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
    children: cells.map((c) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(c, style: pw.TextStyle(color: PdfColors.white,
          fontWeight: pw.FontWeight.bold, fontSize: 11)),
    )).toList(),
  );

  pw.TableRow _pdfRow(List<String> cells) => pw.TableRow(
    children: cells.map((c) => pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(c, style: const pw.TextStyle(fontSize: 10)),
    )).toList(),
  );
}

// ── Tab bar ───────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final String selected; final List<String> tabs; final void Function(String) onChanged;
  const _TabBar({required this.selected, required this.tabs, required this.onChanged});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: tabs.map((t) {
      final sel = selected == t;
      return GestureDetector(
        onTap: () => onChanged(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppColors.accentBlue : AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? AppColors.accentBlue : AppColors.bgCardBorder),
          ),
          child: Text(t, style: TextStyle(
            color: sel ? Colors.white : AppColors.textSecondary,
            fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
          )),
        ),
      );
    }).toList()),
  );
}

// ── Summary Tab ───────────────────────────────────────────────────────────────
class _SummaryTab extends StatelessWidget {
  final String monthName;
  final double income, expense, saving, savPct;
  const _SummaryTab({required this.monthName, required this.income,
      required this.expense, required this.saving, required this.savPct});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Month header card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A3A8F), Color(0xFF0E1F5B)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(monthName, style: const TextStyle(color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Monthly Summary', style: TextStyle(color: AppColors.accentBlue, fontSize: 13)),
          ])),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 28)),
        ]),
      ),
      const SizedBox(height: 16),
      // Stats
      ...[
        _ReportRow(icon: Icons.trending_up_rounded, label: 'Total Income',
            value: Formatters.currency(income), color: AppColors.green),
        _ReportRow(icon: Icons.trending_down_rounded, label: 'Total Expenses',
            value: Formatters.currency(expense), color: AppColors.red),
        _ReportRow(icon: Icons.savings_rounded, label: 'Net Savings',
            value: Formatters.currency(saving), color: saving >= 0 ? AppColors.green : AppColors.red),
        _ReportRow(icon: Icons.percent_rounded, label: 'Savings Percentage',
            value: '${savPct.toStringAsFixed(1)}%', color: AppColors.yellow),
      ],
    ]);
  }
}

// ── Income Tab ────────────────────────────────────────────────────────────────
class _IncomeTab extends StatelessWidget {
  final IncomeProvider ip;
  const _IncomeTab({required this.ip});

  @override
  Widget build(BuildContext context) {
    if (ip.incomes.isEmpty) return const Center(
      child: Padding(padding: EdgeInsets.only(top: 40),
        child: Text('No income data', style: TextStyle(color: AppColors.textSecondary))));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(title: 'Income Summary', children: ip.incomes.map((i) =>
          _ReportRow(icon: Icons.attach_money_rounded, label: i.category,
              value: Formatters.currency(i.amount), color: AppColors.green,
              subtitle: i.remarks)).toList()),
        const SizedBox(height: 12),
        _SectionCard(title: 'Total', children: [
          _ReportRow(icon: Icons.summarize_rounded, label: 'Total Credited',
              value: Formatters.currency(ip.totalIncome), color: AppColors.green),
        ]),
      ],
    );
  }
}

// ── Expenses Tab ──────────────────────────────────────────────────────────────
class _ExpensesTab extends StatelessWidget {
  final ExpenseProvider ep;
  const _ExpensesTab({required this.ep});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionCard(title: 'Daily Expenses by Category',
        children: ep.byCategory.entries.map((e) =>
          _ReportRow(icon: Icons.receipt_long_rounded, label: e.key,
              value: Formatters.currency(e.value), color: AppColors.red)).toList()),
      const SizedBox(height: 12),
      _SectionCard(title: 'Monthly Bills',
        children: ep.bills.map((b) =>
          _ReportRow(icon: Icons.receipt_rounded, label: b.category,
              value: Formatters.currency(b.amount), color: AppColors.accentBlue,
              subtitle: b.remarks)).toList()),
      const SizedBox(height: 12),
      _SectionCard(title: 'Total', children: [
        _ReportRow(icon: Icons.summarize_rounded, label: 'All Expenses',
            value: Formatters.currency(ep.totalAllExpenses), color: AppColors.red),
      ]),
    ]);
  }
}

// ── Loans Tab ─────────────────────────────────────────────────────────────────
class _LoansTab extends StatelessWidget {
  final LoanProvider lp;
  const _LoansTab({required this.lp});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionCard(title: 'Borrowed (You Owe)',
        children: lp.borrowedLoans.map((l) =>
          _ReportRow(icon: Icons.arrow_downward_rounded, label: l.person,
              value: Formatters.currency(l.pending), color: AppColors.red,
              subtitle: 'Original: ${Formatters.currency(l.originalAmount)}')).toList()),
      const SizedBox(height: 12),
      _SectionCard(title: 'Lent (Owed to You)',
        children: lp.lentLoans.map((l) =>
          _ReportRow(icon: Icons.arrow_upward_rounded, label: l.person,
              value: Formatters.currency(l.pending), color: AppColors.green,
              subtitle: 'Original: ${Formatters.currency(l.originalAmount)}')).toList()),
      const SizedBox(height: 12),
      _SectionCard(title: 'Summary', children: [
        _ReportRow(icon: Icons.arrow_downward_rounded, label: 'Total Borrowed Pending',
            value: Formatters.currency(lp.totalPendingBorrowed), color: AppColors.red),
        _ReportRow(icon: Icons.arrow_upward_rounded, label: 'Total Lent Pending',
            value: Formatters.currency(lp.totalPendingLent), color: AppColors.green),
      ]),
    ]);
  }
}

// ── Shared UI pieces ──────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title; final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14,
            fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 8),
      ...children.map((c) => Column(children: [
        c,
        if (c != children.last) const Divider(height: 1, color: AppColors.bgCardBorder, indent: 56),
      ])),
      const SizedBox(height: 4),
    ]),
  );
}

class _ReportRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color color; final String? subtitle;
  const _ReportRow({required this.icon, required this.label, required this.value,
      required this.color, this.subtitle});

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18)),
    title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    subtitle: subtitle != null && subtitle!.isNotEmpty
        ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))
        : null,
    trailing: Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
  );
}
