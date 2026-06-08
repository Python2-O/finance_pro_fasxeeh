import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PinPad extends StatelessWidget {
  final void Function(String key) onKeyTap;
  final bool showBiometric;
  final VoidCallback? onBiometric;

  const PinPad({
    super.key,
    required this.onKeyTap,
    this.showBiometric = false,
    this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [['1','2','3'],['4','5','6'],['7','8','9']];
    return Column(
      children: [
        ...rows.map((row) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((k) => _PinKey(label: k, onTap: () => onKeyTap(k))).toList(),
          ),
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            showBiometric
                ? _PinKey(
                    child: const Icon(Icons.fingerprint, color: Colors.white, size: 28),
                    onTap: onBiometric ?? () {},
                  )
                : const SizedBox(width: 80, height: 80),
            _PinKey(label: '0', onTap: () => onKeyTap('0')),
            _PinKey(
              child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 22),
              onTap: () => onKeyTap('del'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinKey extends StatefulWidget {
  final String? label;
  final Widget? child;
  final VoidCallback onTap;
  const _PinKey({this.label, this.child, required this.onTap});

  @override
  State<_PinKey> createState() => _PinKeyState();
}

class _PinKeyState extends State<_PinKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 78, height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? AppColors.accentBlue.withOpacity(0.3)
              : AppColors.bgCardLight,
          border: Border.all(
            color: _pressed
                ? AppColors.accentBlue
                : AppColors.bgCardBorder,
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [BoxShadow(
                  color: AppColors.accentBlue.withOpacity(0.3),
                  blurRadius: 12, spreadRadius: 2,
                )]
              : null,
        ),
        alignment: Alignment.center,
        child: widget.label != null
            ? Text(
                widget.label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                ),
              )
            : widget.child,
      ),
    );
  }
}
