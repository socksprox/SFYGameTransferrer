import 'package:flutter/material.dart';

class CenteredButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isPrimary;
  final bool isLarge;
  final bool isBlock;
  final bool disabled;

  const CenteredButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.isPrimary = false,
    this.isLarge = false,
    this.isBlock = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = disabled
        ? Colors.grey.shade300
        : (isPrimary ? const Color(0xFF0052D9) : Colors.white);
    final textColor = disabled
        ? Colors.grey.shade600
        : (isPrimary ? Colors.white : Colors.black87);
    final borderColor = isPrimary
        ? const Color(0xFF0052D9)
        : Colors.grey.shade300;

    return SizedBox(
      width: isBlock ? double.infinity : null,
      height: isLarge ? 48 : 40,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: isBlock ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: isLarge ? 20 : 18, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: isLarge ? 16 : 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
