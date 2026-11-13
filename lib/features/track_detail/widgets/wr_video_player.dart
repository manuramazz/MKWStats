import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Miniatura del vídeo del WR; al tocarla abre el reproductor en un diálogo.
///
/// No se incrusta el reproductor directamente en la sección: en móvil,
/// youtube_player_iframe 6.x dibuja el WebView en un OverlayPortal global,
/// así que el scroll no lo recorta y se pinta encima del footer.
class WrVideoPlayer extends StatelessWidget {
  final String? videoUrl;

  const WrVideoPlayer({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final url = videoUrl;
    final videoId = url == null
        ? null
        : YoutubePlayerController.convertUrlToId(url);
    if (videoId == null) {
      return Text(
        'Vídeo no disponible',
        style: AppTextStyles.interRegular14(color: AppColors.grayMuted),
      );
    }

    return GestureDetector(
      onTap: () => _openPlayer(context, videoId),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppColors.tableDark),
              ),
              const ColoredBox(color: Color(0x33000000)),
              Center(
                child: Container(
                  width: 64,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.activeRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPlayer(BuildContext context, String videoId) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _WrVideoDialog(videoId: videoId),
    );
  }
}

class _WrVideoDialog extends StatefulWidget {
  final String videoId;

  const _WrVideoDialog({required this.videoId});

  @override
  State<_WrVideoDialog> createState() => _WrVideoDialogState();
}

class _WrVideoDialogState extends State<_WrVideoDialog> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.white),
          ),
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
        ],
      ),
    );
  }
}
