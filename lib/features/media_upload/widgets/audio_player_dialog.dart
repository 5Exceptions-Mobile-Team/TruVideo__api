import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/core/utils/blob_url_helper.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/audio_player_helper.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerDialog extends StatefulWidget {
  final String filePath;

  const AudioPlayerDialog({
    super.key,
    required this.filePath,
  });

  @override
  State<AudioPlayerDialog> createState() => _AudioPlayerDialogState();
}

class _AudioPlayerDialogState extends State<AudioPlayerDialog> {
  dynamic _audioElement; // For web
  AudioPlayer? _audioPlayer; // For mobile
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioUrl;
  String? _tempFilePath; // For mobile web media files

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb && widget.filePath.startsWith('web_media_')) {
        // Web: Use HTML audio element
        final webStorage = WebMediaStorageService();
        final id = widget.filePath.replaceFirst('web_media_', '');
        final bytes = await webStorage.getMediaBytes(id);
        if (bytes != null) {
          _audioUrl = BlobUrlHelper.createBlobUrl(bytes, mimeType: 'audio/mpeg');
          if (_audioUrl != null) {
            _audioElement = AudioPlayerHelper.createAudioElement();
            AudioPlayerHelper.setSource(_audioElement, _audioUrl!);
            
            AudioPlayerHelper.listenToLoadedMetadata(_audioElement, () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _duration = AudioPlayerHelper.getDuration(_audioElement);
                });
              }
            });
            
            AudioPlayerHelper.listenToPlay(_audioElement, () {
              if (mounted) {
                setState(() => _isPlaying = true);
              }
            });
            
            AudioPlayerHelper.listenToPause(_audioElement, () {
              if (mounted) {
                setState(() => _isPlaying = false);
              }
            });
            
            AudioPlayerHelper.listenToEnded(_audioElement, () {
              if (mounted) {
                setState(() => _isPlaying = false);
              }
            });
            
            AudioPlayerHelper.listenToTimeUpdate(_audioElement, () {
              if (mounted) {
                setState(() {
                  _position = AudioPlayerHelper.getCurrentTime(_audioElement);
                  _duration = AudioPlayerHelper.getDuration(_audioElement);
                });
              }
            });
          }
        }
      } else {
        // Mobile/Desktop: Use audioplayers package
        _audioPlayer = AudioPlayer();
        
        String audioPath = widget.filePath;
        
        // If it's a web_media_ path on mobile (shouldn't happen, but handle it)
        if (widget.filePath.startsWith('web_media_')) {
          final webStorage = WebMediaStorageService();
          final id = widget.filePath.replaceFirst('web_media_', '');
          final bytes = await webStorage.getMediaBytes(id);
          if (bytes != null) {
            // Save to temporary file
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/audio_$id.mp3');
            await tempFile.writeAsBytes(bytes);
            audioPath = tempFile.path;
            _tempFilePath = audioPath;
          }
        }
        
        // Set up event listeners
        _audioPlayer!.onDurationChanged.listen((duration) {
          if (mounted) {
            setState(() {
              _duration = duration;
            });
          }
        });
        
        _audioPlayer!.onPositionChanged.listen((position) {
          if (mounted) {
            setState(() {
              _position = position;
            });
          }
        });
        
        _audioPlayer!.onPlayerStateChanged.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state == PlayerState.playing;
            });
          }
        });
        
        _audioPlayer!.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _position = Duration.zero;
            });
          }
        });
        
        // Load the audio file
        await _audioPlayer!.setSource(DeviceFileSource(audioPath));
        
        // Get duration
        final duration = await _audioPlayer!.getDuration();
        if (duration != null && mounted) {
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load audio file: ${e.toString()}',
          backgroundColor: Pallet.errorColor,
          colorText: Colors.white,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _togglePlayPause() async {
    if (_isLoading) return;

    if (kIsWeb) {
      if (_audioElement == null) return;
      if (_isPlaying) {
        AudioPlayerHelper.pause(_audioElement);
      } else {
        AudioPlayerHelper.play(_audioElement);
      }
    } else {
      if (_audioPlayer == null) return;
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.resume();
      }
    }
  }
  
  void _seek(Duration position) async {
    if (kIsWeb) {
      if (_audioElement != null) {
        AudioPlayerHelper.seek(_audioElement, position);
      }
    } else {
      if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
      }
    }
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }


  @override
  void dispose() {
    if (kIsWeb) {
      if (_audioElement != null) {
        AudioPlayerHelper.dispose(_audioElement);
      }
      if (_audioUrl != null) {
        BlobUrlHelper.revokeBlobUrl(_audioUrl!);
      }
    } else {
      _audioPlayer?.dispose();
      // Clean up temporary file if created
      if (_tempFilePath != null) {
        try {
          final file = File(_tempFilePath!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Pallet.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Pallet.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Pallet.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Audio Player',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Pallet.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                  color: Pallet.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Audio Visualizer/Icon
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Pallet.primaryColor.withOpacity(0.8),
                    Pallet.primaryColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress Bar
            if (!_isLoading && _duration != Duration.zero && ((kIsWeb && _audioElement != null) || (!kIsWeb && _audioPlayer != null))) ...[
              Slider(
                value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _seek(Duration(seconds: value.toInt()));
                },
                activeColor: Pallet.primaryColor,
                inactiveColor: Pallet.primaryColor.withOpacity(0.3),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Pallet.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Pallet.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Pallet.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Pallet.primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
