import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Numeric PIN pad widget
class PinPad extends StatelessWidget {
  final void Function(String digit) onDigitPressed;
  final VoidCallback onDeletePressed;

  const PinPad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildRow(['', '0', 'delete']),
      ],
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((button) {
        if (button.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        } else if (button == 'delete') {
          return _PinButton(
            onPressed: onDeletePressed,
            child: const Icon(
              Icons.backspace_outlined,
              color: SelonaColors.textPrimary,
              size: 24,
            ),
          );
        } else {
          return _PinButton(
            onPressed: () => onDigitPressed(button),
            child: Text(
              button,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: SelonaColors.textPrimary,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}

class _PinButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PinButton({
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(40),
          splashColor: SelonaColors.primaryAccent.withAlpha(51),
          highlightColor: SelonaColors.primaryAccent.withAlpha(26),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SelonaColors.border,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
