import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../widgets/bottom_button_padding.dart';
import '../../../services/file_picker_service.dart';
import '../agora_rtm_service.dart';
import '../models/conversation_model.dart';
import '../sound_player_service.dart';
import '../../../exporter.dart';

ValueNotifier<String?> repliedText = ValueNotifier(null);

class ChatBottomBar extends StatefulWidget {
  final ConversationModel conversation;

  const ChatBottomBar({super.key, required this.conversation});

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> {
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<bool> isFocused = ValueNotifier(false);
  final RecorderController recorderController = RecorderController();
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
    repliedText.addListener(onReplied);
    super.initState();
  }

  void onReplied() {
    if (repliedText.value != null) {
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    _elapsedDuration.dispose();
    _isVoiceRecording.dispose();
    _isVoicePaused.dispose();
    messageController.dispose();
    isFocused.dispose();
    focusNode.dispose();
    _timer?.cancel();
    repliedText.removeListener(onReplied);
    super.dispose();
  }

  void startRecording() {
    _elapsedDuration.value = Duration.zero;
    _isVoicePaused.value = false;
    _isVoiceRecording.value = true;
    recorderController.record();
    _startTimer();
  }

  void pauseRecording() {
    recorderController.pause();
    _isVoicePaused.value = true;
    _stopTimer();
  }

  void resumeRecording() {
    recorderController.record();
    _isVoicePaused.value = false;

    _startTimer();
  }

  void stopRecording() {
    recorderController.stop();

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

  void sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    final replyData = repliedText.value != null
        ? ReplyMessageData.fromMessageAttributes(jsonDecode(repliedText.value!))
        : null;

    await AgoraRTMService.i.sendMessageWithReply(
      id: widget.conversation.conversation.id,
      message: message,
      replyToMessageId: replyData?.messageId,
      replyToContent: replyData?.content,
      replyToSender: replyData?.senderName,
      replyToType: replyData?.messageType,
    );
    messageController.clear();
    repliedText.value = null;
    SoundPlayerService.i.playMsgSendAudio();
    HapticFeedback.lightImpact();
  }

  void sendFile(File file) async {
    final replyData = repliedText.value != null
        ? ReplyMessageData.fromMessageAttributes(jsonDecode(repliedText.value!))
        : null;

    await AgoraRTMService.i.sendFileMessageWithReply(
      id: widget.conversation.conversation.id,
      file: file,
      replyToMessageId: replyData?.messageId,
      replyToContent: replyData?.content,
      replyToSender: replyData?.senderName,
      replyToType: replyData?.messageType,
    );

    repliedText.value = null;
    HapticFeedback.lightImpact();
  }

  void sendImage(File image) async {
    final replyData = repliedText.value != null
        ? ReplyMessageData.fromMessageAttributes(jsonDecode(repliedText.value!))
        : null;

    await AgoraRTMService.i.sendImageMessageWithReply(
      id: widget.conversation.conversation.id,
      file: image,
      replyToMessageId: replyData?.messageId,
      replyToContent: replyData?.content,
      replyToSender: replyData?.senderName,
      replyToType: replyData?.messageType,
    );

    repliedText.value = null;
    HapticFeedback.lightImpact();
  }

  void sendVoice(String? voicePath) async {
    if (voicePath == null) return;
    final replyData = repliedText.value != null
        ? ReplyMessageData.fromMessageAttributes(jsonDecode(repliedText.value!))
        : null;

    await AgoraRTMService.i.sendVoiceMessageWithReply(
      id: widget.conversation.conversation.id,
      file: File(voicePath),
      duration: recorderController.recordedDuration,
      replyToMessageId: replyData?.messageId,
      replyToContent: replyData?.content,
      replyToSender: replyData?.senderName,
      replyToType: replyData?.messageType,
    );

    repliedText.value = null;
    _isVoiceRecording.value = false;
    _stopTimer();
    setState(() {});
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (recorderController.isRecording) {
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
                      style: context.montserrat50013,
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
                    size: Size(ScreenUtil().screenWidth, kToolbarHeight),
                    recorderController: recorderController,
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
                      recorderController.stop().then((value) async {
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
                      if (recorderController.isRecording) {
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
                          return Icon(value ? Iconsax.pause5 : Iconsax.play5);
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
                      recorderController.stop().then((value) {
                        setState(() {});
                        if (value == null) return;
                        sendVoice(value);
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: repliedText,
            builder: (context, replyJson, child) {
              if (replyJson == null) return SizedBox.shrink();

              final replyData = ReplyMessageData.fromMessageAttributes(
                jsonDecode(replyJson),
              );

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(paddingLarge),
                    topRight: Radius.circular(paddingLarge),
                  ),
                ),
                child: Row(
                  children: [
                    Container(width: 4, height: 50.h, color: Color(0xFF832FB7)),
                    Gap(padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replyData?.senderName ?? 'Unknown',
                            style: context.montserrat60013.copyWith(
                              color: Color(0xFF832FB7),
                            ),
                          ),
                          Text(
                            replyData?.content ?? '',
                            style: context.montserrat40012,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => repliedText.value = null,
                      icon: Icon(Iconsax.close_circle5, size: 20.sp),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
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
                    sendFile(file);
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
                              final permission = await Permission.camera
                                  .request();
                              if (permission ==
                                  PermissionStatus.permanentlyDenied) {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Camera Acces Required',
                                      style: context.montserrat60016,
                                    ),
                                    content: Text(
                                      'Please enable camera permission in settings in order to take pictures',
                                      style: context.montserrat40014,
                                    ),

                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          openAppSettings();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Open Setttigs',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final image =
                                  await FilePickerService.pickFromCamera();
                              if (image == null) return;
                              sendImage(image);
                              HapticFeedback.lightImpact();
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
                              final permisson = await Permission.microphone
                                  .request();
                              if (permisson ==
                                  PermissionStatus.permanentlyDenied) {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Microphone Acces Required',
                                      style: context.montserrat60016,
                                    ),
                                    content: Text(
                                      'Please enable microphone permission in settings in order to make calls',
                                      style: context.montserrat40014,
                                    ),

                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          openAppSettings();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Open Setttigs',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              if (permisson != PermissionStatus.granted) return;
                              _isVoiceRecording.value = true;
                              _startTimer();
                              recorderController.record().then((value) {
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
                        onTap: () {
                          sendMessage();
                        },
                        child: Center(
                          child: Icon(Icons.send, color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
