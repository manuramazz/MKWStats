import 'package:flutter/material.dart';

import '../../features/session/logout_modal.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppFooter extends StatelessWidget {
  final String username;
  final VoidCallback onAddTap;

  const AppFooter({super.key, required this.username, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navbarBrown,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.videogame_asset, color: AppColors.grayMuted),
            ),
          ),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 46,
              height: 46,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    username,
                    style: AppTextStyles.bangers18(color: AppColors.grayLight),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => showLogoutModal(context),
                    child: const Icon(Icons.logout, color: AppColors.grayLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
