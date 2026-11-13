import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/build_type.dart';
import '../../../core/i18n/i18n.dart';

class ComboToggle extends StatelessWidget {
  final BuildType value;
  final ValueChanged<BuildType> onChanged;
  final double fontSize;

  const ComboToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ComboOption(
            icon: Icons.bolt,
            label: t('home.combo_time_trial'),
            isActive: value == BuildType.optimal,
            fontSize: fontSize,
            onTap: () => onChanged(BuildType.optimal),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ComboOption(
            icon: Icons.wifi,
            label: t('home.combo_online_meta'),
            isActive: value == BuildType.meta,
            fontSize: fontSize,
            onTap: () => onChanged(BuildType.meta),
          ),
        ),
      ],
    );
  }
}

class _ComboOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final double fontSize;
  final VoidCallback onTap;

  const _ComboOption({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.white : AppColors.grayMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppColors.activeRed, width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bangers(fontSize: fontSize, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
