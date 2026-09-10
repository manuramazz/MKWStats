import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WrVideoPlayer extends StatefulWidget {
  final String? videoUrl;

  const WrVideoPlayer({super.key, required this.videoUrl});

  @override
  State<WrVideoPlayer> createState() => _WrVideoPlayerState();
}

class _WrVideoPlayerState extends State<WrVideoPlayer> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final url = widget.videoUrl;
    if (url != null) {
      final videoId = YoutubePlayerController.convertUrlToId(url);
      if (videoId != null) {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: false,
          params: const YoutubePlayerParams(showFullscreenButton: true),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return Text(
        'Vídeo no disponible',
        style: AppTextStyles.interRegular14(color: AppColors.grayMuted),
      );
    }

    return YoutubePlayer(controller: controller, aspectRatio: 16 / 9);
  }
}
