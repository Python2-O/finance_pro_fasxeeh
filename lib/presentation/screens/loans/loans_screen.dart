import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/loan_provider.dart';
import '../../../data/models/loan_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(builder: (_, lp, __) {
      final allLoans = lp.allLoans.where((l) => !l.isSettled).toList();

      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          leading: const Icon(Icons.menu_rounded, color: AppColors.textSecondary),
          title: const Text('Loans'), centerTitle: true,
          actions: [
            IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.accentBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () => _showForm(context, lp, 'borrowed'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: CustomScrollView(slivers: [
          // Total Pending Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _TotalPendingCard(
                total: lp.totalPendingBorrowed,
                lp: lp,
              ),
            ),
          ),
          // Loan list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: allLoans.isEmpty
                ? SliverToBoxAdapter(child: _emptyState(context, lp))
                : SliverList(delegate: SliverChildBuilderDelegate(
                    (_, i) => _LoanCard(
                      loan: allLoans[i],
                      onEdit: () => _showForm(context, lp, allLoans[i].type, existing: allLoans[i]),
                      onDelete: () => lp.deleteLoan(allLoans[i].id!),
                      onSettle: () => lp.settleLoan(allLoans[i].id!),
                    ),
                    childCount: allLoans.length,
                  )),
          ),
        ]),
      );
    });
  }

  Widget _emptyState(BuildContext ctx, LoanProvider lp) => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(children: [
        const Icon(Icons.account_balance_outlined, size: 60, color: AppColors.bgCardBorder),
        const SizedBox(height: 12),
        const Text('No active loans', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            onPressed: () => _showForm(ctx, lp, 'borrowed'),
            icon: const Icon(Icons.arrow_downward_rounded, size: 16),
            label: const Text('Borrowed'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _showForm(ctx, lp, 'lent'),
            icon: const Icon(Icons.arrow_upward_rounded, size: 16),
            label: const Text('Lent'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          ),
        ]),
      ]),
    ),
  );

  Future<void> _showForm(BuildContext ctx, LoanProvider lp, String type, {LoanModel? existing}) async {
    await showModalBottomSheet(
      context: ctx, isScrollControlled: true, backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LoanFormSheet(type: type, existing: existing, onSave: (loan) async {
        if (existing != null) await lp.updateLoan(loan); else await lp.addLoan(loan);
      }),
    );
  }
}

// ── Total Pending Card ────────────────────────────────────────────────────────
class _TotalPendingCard extends StatelessWidget {
  final double total;
  final LoanProvider lp;
  const _TotalPendingCard({required this.total, required this.lp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1040), Color(0xFF0F0A28)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.purple.withOpacity(0.3)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Pending Loans',
                style: TextStyle(color: AppColors.purple.withOpacity(0.8), fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(Formatters.currency(total),
                style: const TextStyle(color: Colors.white, fontSize: 26,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.red)),
              const SizedBox(width: 6),
              Text('Borrowed: ${Formatters.currencyCompact(lp.totalPendingBorrowed)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(width: 12),
              Container(width: 8, height: 8, decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.green)),
              const SizedBox(width: 6),
              Text('Lent: ${Formatters.currencyCompact(lp.totalPendingLent)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

// ── Loan Card ─────────────────────────────────────────────────────────────────
class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onEdit, onDelete, onSettle;
  const _LoanCard({required this.loan, required this.onEdit, required this.onDelete, required this.onSettle});

  @override
  Widget build(BuildContext context) {
    final isBorrowed = loan.isBorrowed;
    final color = isBorrowed ? AppColors.red : AppColors.green;
    final paidPct = loan.originalAmount > 0
        ? (loan.paidOrReceived / loan.originalAmount).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onLongPress: () => showModalBottomSheet(
        context: context, backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.edit_rounded, color: AppColors.accentBlue),
              title: const Text('Edit', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); onEdit(); }),
          if (!loan.isSettled)
            ListTile(leading: const Icon(Icons.check_circle_rounded, color: AppColors.green),
                title: const Text('Mark Settled', style: TextStyle(color: AppColors.green)), onTap: () { Navigator.pop(context); onSettle(); }),
          ListTile(leading: const Icon(Icons.delete_rounded, color: AppColors.red),
              title: const Text('Delete', style: TextStyle(color: AppColors.red)), onTap: () { Navigator.pop(context); onDelete(); }),
        ])),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bgCardBorder),
        ),
        child: Column(children: [
          Row(children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5)),
              child: Center(child: Text(
                loan.person.isNotEmpty ? loan.person[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(loan.person, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              if (loan.remarks != null && loan.remarks!.isNotEmpty)
                Text(loan.remarks!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(Formatters.currency(loan.originalAmount),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '${(paidPct * 100).toInt()}%',
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: paidPct, minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Paid', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text(Formatters.currencyCompact(loan.paidOrReceived),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Pending', style: TextStyle(color: color, fontSize: 10)),
              Text(Formatters.currencyCompact(loan.pending),
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ])),
          ]),
        ]),
      ),
    );
  }
}

// ── Loan Form ─────────────────────────────────────────────────────────────────
class _LoanFormSheet extends StatefulWidget {
  final String type; final LoanModel? existing;
  final void Function(LoanModel) onSave;
  const _LoanFormSheet({required this.type, this.existing, required this.onSave});
  @override State<_LoanFormSheet> createState() => _LoanFormSheetState();
}
class _LoanFormSheetState extends State<_LoanFormSheet> {
  final _personCtrl = TextEditingController(); final _amtCtrl = TextEditingController();
  final _paidCtrl = TextEditingController(); final _remCtrl = TextEditingController();
  late String _type;

  @override
  void initState() {
    super.initState(); _type = widget.type;
    if (widget.existing != null) {
      final e = widget.existing!; _type = e.type;
      _personCtrl.text = e.person; _amtCtrl.text = e.originalAmount.toString();
      _paidCtrl.text = e.paidOrReceived.toString(); _remCtrl.text = e.remarks ?? '';
    }
  }

  @override void dispose() { _personCtrl.dispose(); _amtCtrl.dispose(); _paidCtrl.dispose(); _remCtrl.dispose(); super.dispose(); }

  void _save() {
    if (_personCtrl.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name'))); return; }
    final amt = double.tryParse(_amtCtrl.text.trim());
    if (amt == null || amt <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount'))); return; }
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;
    final now = DateTime.now().toIso8601String();
    widget.onSave(LoanModel(id: widget.existing?.id, type: _type, person: _personCtrl.text.trim(),
        originalAmount: amt, paidOrReceived: paid, remarks: _remCtrl.text.trim().isEmpty ? null : _remCtrl.text.trim(),
        isSettled: widget.existing?.isSettled ?? false, createdAt: widget.existing?.createdAt ?? now));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isBorrowed = _type == 'borrowed';
    final color = isBorrowed ? AppColors.red : AppColors.green;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.existing != null ? 'Edit Loan' : isBorrowed ? 'Add Borrowed Loan' : 'Add Lent Loan',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary), onPressed: () => Navigator.pop(context)),
        ]),
        // Type switcher
        if (widget.existing == null) ...[
          const SizedBox(height: 12),
          Row(children: ['borrowed', 'lent'].map((t) {
            final sel = _type == t;
            final c = t == 'borrowed' ? AppColors.red : AppColors.green;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: t == 'borrowed' ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? c.withOpacity(0.2) : AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? c : AppColors.bgCardBorder),
                ),
                child: Text(t == 'borrowed' ? '⬇ Borrowed' : '⬆ Lent',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: sel ? c : AppColors.textSecondary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            ));
          }).toList()),
        ],
        const SizedBox(height: 16),
        TextField(controller: _personCtrl, style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(labelText: isBorrowed ? 'Person / Source Name' : 'Person Name')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _amtCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Original Amount', prefixText: '₨ '))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _paidCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: isBorrowed ? 'Amount Paid' : 'Amount Received', prefixText: '₨ '))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _remCtrl, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Remarks (optional)')),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: Text(widget.existing != null ? 'Update' : 'Add Loan'))),
      ]),
    );
  }
}
