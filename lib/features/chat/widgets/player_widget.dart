import 'dart:async';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../exporter.dart';

// This code is also used in the example.md. Please keep it up to date.
class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key, required this.chat});

  final ChatMessage chat;

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  late final AudioPlayer player;

  ChatVoiceMessageBody get voiceMessage =>
      widget.chat.body as ChatVoiceMessageBody;

  @override
  void initState() {
    // Use initial values from player
    player = AudioPlayer(playerId: widget.chat.msgId);
    _initStreams();
    final Source source;
    if (voiceMessage.remotePath == null) {
      source = AssetSource(voiceMessage.localPath, mimeType: "audio/aac");
    } else {
      source = UrlSource(voiceMessage.remotePath!, mimeType: "audio/aac");
    }
    player.setSource(source);
    _duration = Duration(seconds: voiceMessage.duration);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: [
            GestureDetector(
              key: const Key('play_button'),
              onTap: _isPlaying ? _pause : _play,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: color,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                padding: EdgeInsets.symmetric(horizontal: paddingLarge),
                onChanged: (value) {
                  final duration = _duration;
                  if (duration == null) {
                    return;
                  }
                  final position = value * duration.inMilliseconds;
                  player.seek(Duration(milliseconds: position.round()));
                },
                value:
                    (_position != null &&
                        _duration != null &&
                        _position!.inMilliseconds > 0 &&
                        _position!.inMilliseconds < _duration!.inMilliseconds)
                    ? _position!.inMilliseconds / _duration!.inMilliseconds
                    : 0.0,
              ),
            ),
            Text(
              _position != null
                  ? '${_position?.toMinuteSeconds}'
                  : _duration != null
                  ? "${_duration?.toMinuteSeconds}"
                  : '',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
      logInfo(duration);
      logInfo("duration changed");
    });

    _positionSubscription = player.onPositionChanged.listen((p) {
      setState(() => _position = p);
      logInfo("msg");
      logInfo(p);
    });

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
      logInfo("completed");
    });

    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((
      state,
    ) {
      setState(() {
        _playerState = state;
        logInfo(state);
      });
    });
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }
}
