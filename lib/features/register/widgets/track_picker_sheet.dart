import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/track.dart';

Future<Track?> showTrackPickerSheet(BuildContext context, List<Track> tracks) {
  final sortedTracks = [...tracks]..sort((a, b) => a.name.compareTo(b.name));
  return showModalBottomSheet<Track>(
    context: context,
    backgroundColor: AppColors.tableDark,
    builder: (context) {
      return SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: sortedTracks.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, color: AppColors.pillInactive),
          itemBuilder: (context, index) {
            final track = sortedTracks[index];
            return ListTile(
              title: Text(
                track.name,
                style: AppTextStyles.interRegular14(color: AppColors.white),
              ),
              onTap: () => Navigator.of(context).pop(track),
            );
          },
        ),
      );
    },
  );
}
