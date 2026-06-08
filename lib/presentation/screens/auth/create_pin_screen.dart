import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/pin_pad.dart';
import '../dashboard/main_screen.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});
  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';
  String _confirm = '';
  bool _confirming = false;
  String _error = '';

  void _onKey(String key) {
    setState(() => _error = '');
    String cur = _confirming ? _confirm : _pin;
    if (key == 'del') {
      if (cur.isNotEmpty) cur = cur.substring(0, cur.length - 1);
    } else if (cur.length < 4) {
      cur += key;
    }
    setState(() { _confirming ? _confirm = cur : _pin = cur; });
    if (cur.length == 4 && !_confirming) {
      Future.delayed(const Duration(milliseconds: 200),
          () => setState(() => _confirming = true));
    } else if (cur.length == 4 && _confirming) {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_pin == _confirm) {
      await context.read<AuthProvider>().createPin(_pin);
      if (mounted) Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      setState(() { _error = 'PINs do not match. Try again.'; _pin = ''; _confirm = ''; _confirming = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cur = _confirming ? _confirm : _pin;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: _confirming
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                onPressed: () => setState(() { _confirming = false; _confirm = ''; }),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue.withOpacity(0.15),
                  border: Border.all(color: AppColors.accentBlue.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.accentBlue, size: 30),
              ),
              const SizedBox(height: 24),
              const Text('Create 4 Digit PIN',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                _confirming ? 'Confirm your PIN' : 'Set a PIN to secure your account',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < cur.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.accentBlue : Colors.transparent,
                      border: Border.all(
                        color: filled ? AppColors.accentBlue : AppColors.textSecondary,
                        width: 2,
                      ),
                      boxShadow: filled ? [BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.5), blurRadius: 8)] : null,
                    ),
                  );
                }),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(_error, style: const TextStyle(color: AppColors.red, fontSize: 13)),
              ],
              const Spacer(),
              PinPad(onKeyTap: _onKey),
              const SizedBox(height: 20),
              if (_confirming)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirm.length == 4 ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Set PIN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
