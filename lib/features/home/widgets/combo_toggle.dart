import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/build_type.dart';

class ComboToggle extends StatelessWidget {
  final BuildType value;
  final ValueChanged<BuildType> onChanged;

  const ComboToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ComboOption(
            icon: Icons.bolt,
            label: 'Time Trial combo',
            isActive: value == BuildType.optimal,
            onTap: () => onChanged(BuildType.optimal),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ComboOption(
            icon: Icons.wifi,
            label: 'online meta combo',
            isActive: value == BuildType.meta,
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
  final VoidCallback onTap;

  const _ComboOption({
    required this.icon,
    required this.label,
    required this.isActive,
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
                style: AppTextStyles.bangers15(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
