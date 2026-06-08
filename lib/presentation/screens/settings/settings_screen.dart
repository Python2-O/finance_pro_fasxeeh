import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/month_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/pin_screen.dart';
import '../../widgets/pin_pad.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: const Icon(Icons.menu_rounded, color: AppColors.textSecondary),
        title: const Text('Settings'), centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(children: [
          // Profile Card
          _ProfileCard(),
          const SizedBox(height: 20),

          // Settings list
          _SettingsCard(children: [
            Consumer<AuthProvider>(builder: (_, auth, __) => _SettingsItem(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.accentBlue,
              title: 'Change PIN',
              onTap: () => _showChangePIN(context),
            )),
            Consumer<AuthProvider>(builder: (_, auth, __) => _SettingsItem(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.green,
              title: 'Fingerprint Unlock',
              trailing: Switch(
                value: auth.biometricEnabled,
                onChanged: auth.biometricAvailable ? (v) => auth.toggleBiometric(v) : null,
                activeColor: AppColors.accentBlue,
                thumbColor: WidgetStateProperty.all(Colors.white),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            )),
            _SettingsItem(
              icon: Icons.timer_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Auto Lock',
              trailing: const Text('1 min',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.cloud_upload_outlined,
              iconColor: AppColors.accentBlue,
              title: 'Backup & Restore',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.upload_outlined,
              iconColor: AppColors.green,
              title: 'Export Data',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.download_outlined,
              iconColor: AppColors.yellow,
              title: 'Import Data',
              onTap: () {},
            ),
            Consumer<ThemeProvider>(builder: (_, tp, __) => _SettingsItem(
              icon: Icons.dark_mode_rounded,
              iconColor: AppColors.purple,
              title: 'Dark Mode',
              trailing: Switch(
                value: tp.isDark,
                onChanged: (_) => tp.toggleTheme(),
                activeColor: AppColors.accentBlue,
                thumbColor: WidgetStateProperty.all(Colors.white),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            )),
            _SettingsItem(
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.textSecondary,
              title: 'About App',
              onTap: () => _showAbout(context),
            ),
            _SettingsItem(
              icon: Icons.logout_rounded,
              iconColor: AppColors.red,
              title: 'Logout',
              titleColor: AppColors.red,
              showChevron: false,
              onTap: () {
                context.read<AuthProvider>().lock();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PinScreen()),
                  (route) => false,
                );
              },
            ),
          ]),

          const SizedBox(height: 20),
          const Text('Version 1.0.0',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
      ),
    );
  }

  void _showChangePIN(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ChangePINSheet(),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Finance Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.accentBlue, AppColors.accentBlueDark]),
          ),
          child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 34)),
        const SizedBox(height: 12),
        const Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        const Text('by FasXeeH', style: TextStyle(color: AppColors.accentBlue)),
        const SizedBox(height: 8),
        const Text('Track · Save · Grow',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }
}

// ── Profile Card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentBlueDark]),
            ),
            child: const Center(child: Text('F',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
          ),
          Positioned(right: 0, bottom: 0,
            child: Container(width: 14, height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.green,
                border: Border.fromBorderSide(BorderSide(color: AppColors.bgCard, width: 2))),
            ),
          ),
        ]),
        const SizedBox(width: 16),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FasXeeH', style: TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.w700)),
          SizedBox(height: 2),
          Text('Premium User', style: TextStyle(color: AppColors.accentBlue, fontSize: 13)),
        ]),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
          ),
          child: const Text('PRO', style: TextStyle(color: AppColors.accentBlue,
              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ),
      ]),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          return Column(children: [
            e.value,
            if (e.key < children.length - 1)
              const Divider(height: 1, color: AppColors.bgCardBorder, indent: 56, endIndent: 0),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── Settings Item ─────────────────────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor = Colors.white,
    this.onTap,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: TextStyle(color: titleColor, fontSize: 14)),
      trailing: trailing ?? (showChevron
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20)
          : null),
    );
  }
}

// ── Change PIN Sheet ──────────────────────────────────────────────────────────
class _ChangePINSheet extends StatefulWidget {
  const _ChangePINSheet();
  @override
  State<_ChangePINSheet> createState() => _ChangePINSheetState();
}

class _ChangePINSheetState extends State<_ChangePINSheet> {
  int _step = 0; // 0=current, 1=new, 2=confirm
  String _cur = '', _new = '', _conf = '';
  String _error = '';

  String get _input => _step == 0 ? _cur : _step == 1 ? _new : _conf;
  String get _instruction => _step == 0
      ? 'Enter current PIN' : _step == 1
          ? 'Enter new PIN' : 'Confirm new PIN';

  void _onKey(String key) async {
    setState(() => _error = '');
    String val = _input;
    if (key == 'del') {
      if (val.isNotEmpty) val = val.substring(0, val.length - 1);
    } else if (val.length < 4) { val += key; }
    setState(() {
      if (_step == 0) _cur = val;
      else if (_step == 1) _new = val;
      else _conf = val;
    });
    if (val.length == 4) {
      await Future.delayed(const Duration(milliseconds: 150));
      _advance();
    }
  }

  Future<void> _advance() async {
    final auth = context.read<AuthProvider>();
    if (_step == 0) {
      // verify current
      final ok = await auth.verifyPin(_cur);
      if (!ok) {
        setState(() { _error = 'Incorrect current PIN'; _cur = ''; });
        auth.lock();
      } else {
        auth.lock();
        setState(() => _step = 1);
      }
    } else if (_step == 1) {
      setState(() => _step = 2);
    } else {
      if (_new == _conf) {
        await auth.createPin(_new);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PIN changed successfully ✓'),
            backgroundColor: AppColors.green,
          ));
        }
      } else {
        setState(() { _error = 'PINs do not match'; _new = ''; _conf = ''; _step = 1; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dots = _input;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Change PIN',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 8),
          Text(_instruction, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < dots.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppColors.accentBlue : Colors.transparent,
                  border: Border.all(
                    color: filled ? AppColors.accentBlue : AppColors.textSecondary, width: 2),
                ),
              );
            }),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          PinPad(onKeyTap: _onKey),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
