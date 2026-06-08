import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/pin_pad.dart';
import '../dashboard/main_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});
  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }

  Future<void> _tryBiometric() async {
    final auth = context.read<AuthProvider>();
    if (auth.biometricEnabled && auth.biometricAvailable) {
      final ok = await auth.authenticateWithBiometric();
      if (ok && mounted) _goHome();
    }
  }

  void _goHome() => Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()));

  void _onKey(String key) async {
    context.read<AuthProvider>().clearError();
    if (key == 'del') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (_pin.length < 4) {
      setState(() => _pin += key);
      if (_pin.length == 4) {
        await Future.delayed(const Duration(milliseconds: 150));
        final ok = await context.read<AuthProvider>().verifyPin(_pin);
        if (ok) { _goHome(); }
        else {
          _shakeCtrl.forward(from: 0);
          setState(() => _pin = '');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Shield icon
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentBlue.withOpacity(0.15),
                    border: Border.all(color: AppColors.accentBlue.withOpacity(0.5), width: 1.5),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: AppColors.accentBlue, size: 32),
                ),
                const SizedBox(height: 24),
                const Text('Welcome Back',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Enter your 4 digit PIN',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 48),
                // PIN dots
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _shakeAnim.value * 8 * ((_shakeCtrl.value * 10).round() % 2 == 0 ? 1 : -1),
                      0,
                    ),
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = i < _pin.length;
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
                            color: AppColors.accentBlue.withOpacity(0.5),
                            blurRadius: 8,
                          )] : null,
                        ),
                      );
                    }),
                  ),
                ),
                if (auth.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(auth.errorMessage,
                      style: const TextStyle(color: AppColors.red, fontSize: 13)),
                ],
                const Spacer(),
                PinPad(
                  onKeyTap: _onKey,
                  showBiometric: auth.biometricEnabled && auth.biometricAvailable,
                  onBiometric: _tryBiometric,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot PIN?',
                      style: TextStyle(color: AppColors.accentBlue, fontSize: 14)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    });
  }
}
