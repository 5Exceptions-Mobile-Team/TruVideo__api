import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class DemoVideoPlayer extends StatefulWidget {
  const DemoVideoPlayer({super.key});

  @override
  State<DemoVideoPlayer> createState() => _DemoVideoPlayerState();
}

class _DemoVideoPlayerState extends State<DemoVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.asset(
        'assets/videos/video_platform_demo.mp4',
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey.withOpacity(0.3),
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final maxHeight = isDesktop ? 380.0 : null;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline_rounded,
                        size: 22,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'See how Video Platform can help you',
                        style: GoogleFonts.inter(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Video Player
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: _isLoading
                    ? Container(
                        width: double.infinity,
                        height: maxHeight ?? 250,
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : _hasError
                    ? Container(
                        width: double.infinity,
                        height: maxHeight ?? 250,
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  _errorMessage ?? 'Failed to load video',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxHeight ?? double.infinity,
                          ),
                          child: AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
