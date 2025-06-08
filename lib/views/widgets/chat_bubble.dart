import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final bool showActions;
  final Widget? extraAction;
  final String? voiceUrl;
  final String messageType;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.showActions = false,
    this.extraAction,
    this.voiceUrl,
    this.messageType = 'text',
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.messageType == 'voice' && widget.voiceUrl != null) {
      _setupAudioPlayer();
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPauseAudio() async {
    if (widget.voiceUrl == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.voiceUrl!));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi phát âm thanh: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: widget.isUser ? 50 : 0,
        right: widget.isUser ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment:
            widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  widget.isUser ? Colors.blue.shade600 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight:
                    widget.isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                bottomLeft:
                    widget.isUser
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị voice message nếu có
                if (widget.messageType == 'voice' && widget.voiceUrl != null)
                  _buildVoiceMessage(),

                // Hiển thị text message
                if (widget.message.isNotEmpty)
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
              ],
            ),
          ),

          // Actions cho tin nhắn bot
          if (widget.showActions && !widget.isUser)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút copy
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                    onPressed: () {
                      // Implement copy functionality
                    },
                    tooltip: 'Sao chép',
                  ),

                  // Nút like/dislike
                  IconButton(
                    icon: const Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // Implement like functionality
                    },
                    tooltip: 'Thích',
                  ),

                  // Extra action nếu có
                  if (widget.extraAction != null) widget.extraAction!,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút play/pause
          GestureDetector(
            onTap: _playPauseAudio,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isUser
                        ? Colors.white.withOpacity(0.2)
                        : Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.isUser ? Colors.white : Colors.blue.shade700,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Waveform hoặc progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value:
                      _duration.inMilliseconds > 0
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                  backgroundColor:
                      widget.isUser
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isUser ? Colors.white : Colors.blue.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                // Thời gian
                Text(
                  '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        widget.isUser
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
