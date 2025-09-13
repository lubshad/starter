import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../exporter.dart';
import '../sound_player_service.dart';

class ChatVoiceMessageWidget extends StatefulWidget {
  final bool isBottomBar;
  final VoidCallback? onClosePressed;
  final bool isMe;
  const ChatVoiceMessageWidget({
    super.key,
    required this.chat,
    this.onClosePressed,
    this.isBottomBar = false,
    this.isMe = false,
  });

  final ChatMessage chat;

  @override
  State<StatefulWidget> createState() {
    return _ChatVoiceMessageWidgetState();
  }
}

class _ChatVoiceMessageWidgetState extends State<ChatVoiceMessageWidget> {
  ChatVoiceMessageBody get voiceMessage =>
      widget.chat.body as ChatVoiceMessageBody;

  Widget playbackRateButton() {
    return Visibility(
      visible: SoundPlayerService.i.isPlaying(voiceMessage),
      child: GestureDetector(
        onLongPress: () {},
        onTap: () {
          SoundPlayerService.i.resetPlaybackRate();
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: paddingTiny,
              vertical: paddingSmall,
            ),
            width: 50.h,
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.purple.shade50 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(paddingLarge),
            ),
            child: Center(
              child: Text(
                style: context.montserrat40013,
                '${SoundPlayerService.i.currentPlaybackRate % 1 == 0 ? SoundPlayerService.i.currentPlaybackRate.toInt() : SoundPlayerService.i.currentPlaybackRate}x',
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    Widget child = ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: AnimatedBuilder(
        animation: Listenable.merge([SoundPlayerService.i, movingValue]),
        builder: (context, child) {
          return Row(
            children: [
              GestureDetector(
                key: const Key('play_button'),
                onTap: SoundPlayerService.i.isPlaying(voiceMessage)
                    ? () => SoundPlayerService.i.pause()
                    : () => SoundPlayerService.i.play(widget.chat),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Icon(
                    SoundPlayerService.i.isPlaying(voiceMessage)
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: color,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  inactiveColor: widget.isBottomBar ? Colors.grey : null,
                  divisions: 100,
                  padding: EdgeInsets.symmetric(horizontal: paddingLarge),
                  onChangeStart: (value) => SoundPlayerService.i.pause(),
                  onChangeEnd: (value) {
                    movingValue.value = 0;
                    if (!SoundPlayerService.i.isCurrentVoiceMessage(
                      voiceMessage,
                    )) {
                      SoundPlayerService.i.play(widget.chat);
                    } else {
                      SoundPlayerService.i.seekTo(
                        Duration(
                          seconds: (value * voiceMessage.duration).toInt(),
                        ),
                      );
                    }
                  },
                  value: sliderValue,
                  onChanged: (double value) {
                    movingValue.value = value;
                  },
                ),
              ),
              Text(
                sliderValue == 0
                    ? totalDuration.toMinuteSeconds
                    : Duration(
                        seconds: (sliderValue * totalDuration.inSeconds)
                            .toInt(),
                      ).toMinuteSeconds,
                style: TextStyle(fontSize: 10.sp),
              ),
              gap,
              playbackRateButton(),
            ],
          );
        },
      ),
      trailing: widget.isBottomBar
          ? IconButton(
              onPressed:
                  widget.onClosePressed ??
                  () {
                    SoundPlayerService.i.close();
                  },
              icon: Icon(Iconsax.close_circle5),
            )
          : SizedBox(),
    );

    if (widget.isBottomBar) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(padding),
            topRight: Radius.circular(padding),
          ),
          boxShadow: defaultShadow,
          color: Colors.white,
        ),
        child: child,
      );
    }
    return child;
  }

  Duration get totalDuration => Duration(seconds: voiceMessage.duration);

  double get sliderValue =>
      SoundPlayerService.i.isCurrentVoiceMessage(voiceMessage)
      ? movingValue.value != 0
            ? movingValue.value
            : ((SoundPlayerService.i.currentPosition?.inMilliseconds ?? 0) /
                      totalDuration.inMilliseconds)
                  .clamp(0, 1)
      : 0;

  ValueNotifier<double> movingValue = ValueNotifier(0);
}
