import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/i18n.dart';

/// Pide confirmación para cerrar sesión. Devuelve `true` si el usuario
/// confirma; quien llama se encarga de cerrar la sesión.
Future<bool> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => const _LogoutModal(),
  );
  return confirmed ?? false;
}

class _LogoutModal extends StatelessWidget {
  const _LogoutModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.navbarBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.modalBorder, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              t('session.log_out_confirm'),
              textAlign: TextAlign.center,
              style: AppTextStyles.interRegular14(
                color: const Color(0xFFF3F4F6),
              ).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      t('session.log_out_cancel'),
                      style: AppTextStyles.bangers18(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      t('session.log_out_yes'),
                      style: AppTextStyles.bangers20(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
