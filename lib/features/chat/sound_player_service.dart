import 'dart:async';
import 'dart:io';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/logger.dart';

class SoundPlayerService extends ChangeNotifier {
  void close() {
    _player.stop();
    currentMessage = null;
    notifyListeners();
  }

  static SoundPlayerService get i => _instance;
  static final SoundPlayerService _instance = SoundPlayerService._private();

  ChatVoiceMessageBody? get _currentVoiceMessage =>
      currentMessage?.body as ChatVoiceMessageBody?;

  ChatMessage? currentMessage;

  Duration get currentVoiceDuration => _currentVoiceMessage != null
      ? Duration(seconds: _currentVoiceMessage!.duration)
      : Duration.zero;

  final AudioPlayer _player = AudioPlayer();

  SoundPlayerService._private();

  Future<void> playMsgSendAudio() async {
    await _player.play(AssetSource('sounds/message-send.mp3'));
  }

  Future<void> playMsgReceivedAudio() async {
    await _player.play(AssetSource('sounds/message-recieved.mp3'));
  }

  bool isCurrentVoiceMessage(ChatVoiceMessageBody voiceMessage) =>
      _currentVoiceMessage?.localPath == voiceMessage.localPath;

  bool isPlaying(ChatVoiceMessageBody voiceMessage) =>
      isCurrentVoiceMessage(voiceMessage) &&
      _player.state == PlayerState.playing;

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  StreamSubscription? _playerSubscription;
  StreamSubscription? _playerPositionSubscription;
  Duration? currentPosition;

  Future<void> play(ChatMessage message) async {
    if (_player.state == PlayerState.playing) {
      await pause();
    }
    if (!isCurrentVoiceMessage(message.body as ChatVoiceMessageBody)) {
      currentPosition = Duration.zero;
    }

    final Source audioSource;
    currentMessage = message;
    if (File(_currentVoiceMessage!.localPath).existsSync() &&
        File(_currentVoiceMessage!.localPath).lengthSync() > 0) {
      audioSource = DeviceFileSource(_currentVoiceMessage!.localPath);
    } else {
      audioSource = UrlSource(
        _currentVoiceMessage!.remotePath!,
        mimeType: "audio/aac",
      );
    }

    _playerSubscription?.cancel();
    _playerSubscription = _player.onPlayerComplete.listen((event) {
      currentMessage = null;
      notifyListeners();
    });
    _playerPositionSubscription?.cancel();
    _playerPositionSubscription = _player.onPositionChanged.listen((event) {
      currentPosition = event;
      logInfo(event.inMilliseconds);
      notifyListeners();
    });
    await _player.play(audioSource);
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
    await _player.resume();
  }

  @override
  void dispose() {
    super.dispose();
    _playerSubscription?.cancel();
    _playerPositionSubscription?.cancel();
    _player.dispose();
  }
}
