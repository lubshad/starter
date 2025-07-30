import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/bottom_button_padding.dart';
import '../../../services/file_picker_service.dart';
import '../../../services/snackbar_utils.dart';
import '../agora_rtm_service.dart';
import '../models/conversation_model.dart';
import '../sound_player_service.dart';
import '../../../exporter.dart';

class ChatBottomBar extends StatefulWidget {
  final ConversationModel conversation;

  const ChatBottomBar({super.key, required this.conversation});

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> {
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<bool> isFocused = ValueNotifier(false);
  final RecorderController _recorderController = RecorderController();
  final ValueNotifier<Duration> _elapsedDuration = ValueNotifier(Duration.zero);
  final ValueNotifier<bool> _isVoiceRecording = ValueNotifier(false);
  final ValueNotifier<bool> _isVoicePaused = ValueNotifier(false);
  final TextEditingController messageController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
    super.initState();
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _elapsedDuration.dispose();
    _isVoiceRecording.dispose();
    _isVoicePaused.dispose();
    messageController.dispose();
    isFocused.dispose();
    focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startRecording() {
    _elapsedDuration.value = Duration.zero;
    _isVoicePaused.value = false;
    _isVoiceRecording.value = true;
    _recorderController.record();
    _startTimer();
  }

  void pauseRecording() {
    _recorderController.pause();
    _isVoicePaused.value = true;
    _stopTimer();
  }

  void resumeRecording() {
    _recorderController.record();
    _isVoicePaused.value = false;

    _startTimer();
  }

  void stopRecording() {
    _recorderController.stop();

    _isVoiceRecording.value = false;
    _isVoicePaused.value = false;
    _stopTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedDuration.value += Duration(seconds: 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_recorderController.isRecording) {
      return Container(
        height: 130.h,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(0.1.alpha),
              blurRadius: 10,
              offset: Offset(0, -10),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(paddingLarge),
            topRight: Radius.circular(paddingLarge),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                gapLarge,
                ValueListenableBuilder<Duration>(
                  valueListenable: _elapsedDuration,
                  builder: (context, duration, child) {
                    final minutes = duration.inMinutes
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    final seconds = duration.inSeconds
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    return Text(
                      "$minutes:$seconds",
                      style: context.bodySmall,
                    );
                  },
                ),
                gapLarge,
                Expanded(
                  child: AudioWaveforms(
                    waveStyle: WaveStyle(
                      showMiddleLine: false,
                      extendWaveform: true,
                    ),
                    margin: EdgeInsets.symmetric(vertical: padding),
                    size: Size(SizeUtils.width, kToolbarHeight),
                    recorderController: _recorderController,
                  ),
                ),
                gapLarge,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  shadowColor: Colors.black26,
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(padding),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(padding),
                    splashColor: Colors.grey[200],
                    onTap: () async {
                      _recorderController.stop().then((value) async {
                        await File(value!).delete();
                        _elapsedDuration.value = Duration.zero;
                        setState(() {});
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Icon(Icons.delete, color: Colors.red[400]),
                    ),
                  ),
                ),
                Material(
                  elevation: 4.0,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(padding),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(padding),
                    splashColor: Colors.grey[200],
                    onTap: () {
                      if (_recorderController.isRecording) {
                        pauseRecording();
                        _isVoiceRecording.value = false;
                      } else {
                        _isVoiceRecording.value = true;

                        resumeRecording();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isVoiceRecording,
                        builder: (context, value, child) {
                          return Icon(value ? Icons.pause : Icons.play_arrow);
                        },
                      ),
                    ),
                  ),
                ),

                Material(
                  elevation: 4.0,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(padding),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(padding),
                    splashColor: Colors.grey[200],
                    onTap: () {
                      _recorderController.stop().then((value) {
                        setState(() {});
                        if (value == null) return;
                        AgoraRTMService.i
                            .sendVoiceMessage(
                              id: widget.conversation.conversation.id,
                              file: File(value),
                              duration: _recorderController.recordedDuration,
                            )
                            .then((msg) {
                              _isVoiceRecording.value = false;
                              _stopTimer();
                              setState(() {});
                            });
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Icon(Icons.send),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms);
    }
    return BottomButtonPadding(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: kToolbarHeight / 1.2,
              child: TextField(
                controller: messageController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 0,
                  ),
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => AgoraRTMService.i.sendTypingIndicator(
                  id: widget.conversation.conversation.id,
                ),
              ),
            ),
          ),

          gap,
          Material(
            shadowColor: Colors.black26,
            elevation: 4.0,
            borderRadius: BorderRadius.circular(padding),
            color: Colors.white,
            child: InkWell(
              splashColor: Colors.grey[200],
              onTap: () async {
                final file = await FilePickerService.pickFile(
                  fileType: FileType.any,
                );
                if (file == null) return;
                AgoraRTMService.i.sendFileMessage(
                  id: widget.conversation.conversation.id,
                  file: file,
                );
              },
              borderRadius: BorderRadius.circular(padding),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Icon(Icons.attach_file),
              ),
            ),
          ),

          gap,
          ValueListenableBuilder(
            valueListenable: isFocused,
            builder: (context, value, child) {
              if (!value) {
                return Row(
                  children: [
                    Material(
                      shadowColor: Colors.black26,
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(padding),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(padding),
                        splashColor: Colors.grey[200],
                        onTap: () async {
                          final image = await FilePickerService.pickFileOrImage(
                            imageSource: ImageSource.gallery,
                            crop: false,
                          );
                          if (image == null) return;
                          AgoraRTMService.i.sendImageMessage(
                            id: widget.conversation.conversation.id,
                            file: image,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                    gap,
                    Material(
                      shadowColor: Colors.black26,
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(padding),
                      color: Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(padding),
                        splashColor: Colors.grey[200],
                        onTap: () async {
                          if (!(await _recorderController.checkPermission())) {
                            showErrorMessage("You need to give permission");
                            return;
                          }
                          if (!_recorderController.hasPermission) return;
                          _isVoiceRecording.value = true;
                          _startTimer();
                          _recorderController.record().then((value) {
                            setState(() {});
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Icon(Icons.keyboard_voice),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return SizedBox(
                height: 36.h,
                width: 36.h,
                child: Material(
                  shadowColor: Colors.black26,
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(padding),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(padding),
                    splashColor: Colors.grey[200],
                    onTap: () => AgoraRTMService.i
                        .sendMessage(
                          id: widget.conversation.conversation.id,
                          message: messageController.text,
                        )
                        .then((msg) {
                          messageController.clear();
                          SoundPlayerService.i.playMsgSendAudio();
                        }),
                    child: Center(child: Icon(Icons.send, color: Colors.black)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
