import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'centered_button.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.confirmText = 'OK',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? TDTheme.of(context).brandNormalColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TDText(
                    title,
                    font: TDTheme.of(context).fontTitleLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TDText(
              message,
              font: TDTheme.of(context).fontBodyMedium,
              textColor: Colors.grey.shade700,
            ),
            const SizedBox(height: 24),
            if (cancelText != null)
              Row(
                children: [
                  Expanded(
                    child: CenteredButton(
                      text: cancelText!,
                      isPrimary: false,
                      isBlock: true,
                      onTap: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CenteredButton(
                      text: confirmText,
                      isPrimary: true,
                      isBlock: true,
                      onTap: () {
                        Navigator.of(context).pop(true);
                        onConfirm?.call();
                      },
                    ),
                  ),
                ],
              )
            else
              CenteredButton(
                text: confirmText,
                isPrimary: true,
                isBlock: true,
                onTap: () {
                  Navigator.of(context).pop(true);
                  onConfirm?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: cancelText != null,
      builder: (context) => InfoDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
