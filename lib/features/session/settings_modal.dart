import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/auth_repository.dart';
import 'logout_modal.dart';

/// Panel de ajustes de usuario: casi pantalla completa, fondo oscurecido.
/// Se cierra con la X o tocando fuera del panel.
Future<void> showSettingsModal(
  BuildContext context, {
  required String username,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 180),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, _, _) => _SettingsModal(username: username),
  );
}

class _SettingsModal extends StatelessWidget {
  final String username;

  const _SettingsModal({required this.username});

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await confirmLogout(context);
    if (!confirmed || !context.mounted) return;
    Navigator.of(context).pop();
    await AuthRepository().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // El margen alrededor del panel es la zona "fuera" que lo cierra.
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Material(
          color: AppColors.navbarBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.modalBorder, width: 3),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                  Expanded(
                    child: Text(
                      t('session.settings').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bangers20(color: AppColors.white),
                    ),
                  ),
                  // Equilibra la X para que el título quede centrado.
                  const SizedBox(width: 48),
                ],
              ),
              const Divider(color: AppColors.modalBorder, height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      t('session.logged_in_as'),
                      style: AppTextStyles.interRegular14(
                        color: AppColors.grayMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppColors.grayLight,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            username,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bangers(
                              fontSize: 24,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Futuras opciones (cambiar contraseña, foto…) van aquí.
                    OutlinedButton.icon(
                      onPressed: () => _onLogout(context),
                      icon: const Icon(
                        Icons.logout,
                        color: AppColors.dangerRed,
                      ),
                      label: Text(
                        t('session.log_out'),
                        style: AppTextStyles.bangers18(
                          color: AppColors.dangerRed,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.dangerRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
