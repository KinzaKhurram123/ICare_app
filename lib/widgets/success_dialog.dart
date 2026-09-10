import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';

/// The green-tick confirmation dialog, with a way out that isn't the button.
///
/// Every screen used to carry its own copy of this modal, opened with
/// `barrierDismissible: false` and a single "Go Back" button. If that button
/// was ever missed -- off-screen on a short display, or simply not what the
/// person was looking for -- there was no way to close the dialog at all. The
/// client asked for a cross on all of them, so it lives here once instead of
/// being pasted into each screen.
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Go Back',
  VoidCallback? onClose,
}) {
  return showDialog<void>(
    context: context,
    // Tapping outside now closes too; the cross is the visible affordance.
    barrierDismissible: true,
    builder: (ctx) => SuccessDialog(
      title: title,
      message: message,
      buttonLabel: buttonLabel,
      onClose: onClose,
    ),
  );
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onClose;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Go Back',
    this.onClose,
  });

  void _close(BuildContext context) {
    Navigator.of(context).pop();
    onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWide ? 24 : 20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 400 : double.infinity),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(isWide ? 40 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: isWide ? 80 : 70,
                    width: isWide ? 80 : 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: isWide ? 48 : 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWide ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWide ? 15 : 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isWide ? 12 : 30),
                        ),
                      ),
                      onPressed: () => _close(context),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: Color(0xFF94A3B8)),
                tooltip: 'Close',
                onPressed: () => _close(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
