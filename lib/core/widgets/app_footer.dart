import 'package:flutter/material.dart';

import '../../features/session/settings_modal.dart';
import '../i18n/i18n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppFooter extends StatelessWidget {
  /// Se muestra en el modal de ajustes, no en el propio footer.
  final String username;
  final VoidCallback onAddTap;

  const AppFooter({super.key, required this.username, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navbarBrown,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _LanguageMenu(),
            ),
          ),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: t('session.settings'),
                onPressed: () => showSettingsModal(context, username: username),
                icon: const Icon(Icons.settings, color: AppColors.grayLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context) {
    final current = I18n.language.value;
    return PopupMenuButton<AppLanguage>(
      icon: const Icon(Icons.language, color: AppColors.grayLight),
      color: AppColors.navbarBrown,
      // Se abre hacia arriba, por encima del footer.
      position: PopupMenuPosition.over,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.modalBorder),
      ),
      onSelected: I18n.setLanguage,
      itemBuilder: (context) => [
        for (final lang in AppLanguage.values)
          PopupMenuItem(
            value: lang,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: lang == current
                      ? const Icon(
                          Icons.check,
                          color: AppColors.white,
                          size: 18,
                        )
                      : null,
                ),
                Text(
                  t('language.${lang.name}'),
                  style: AppTextStyles.interMedium14(
                    color: lang == current
                        ? AppColors.white
                        : AppColors.grayLight,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
