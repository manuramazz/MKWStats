import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TopPagination extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const TopPagination({
    super.key,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PaginationPill(
          label: 'TIME TRIALS',
          isActive: activeIndex == 0,
          onTap: () => onChanged(0),
        ),
        _PaginationPill(
          label: 'ON LINE',
          isActive: activeIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _PaginationPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PaginationPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.pillInactive : AppColors.tableDark,
          border: isActive
              ? Border.all(color: const Color(0xFF374151), width: 0.5)
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bangers(
            fontSize: 16,
            color: isActive ? AppColors.white : AppColors.grayMuted,
          ),
        ),
      ),
    );
  }
}
