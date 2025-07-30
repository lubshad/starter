import 'package:flutter/material.dart';

import '../../../exporter.dart';

class ChatReactions extends StatelessWidget {
  final void Function(String emoji) onEmojiSelected;
  final VoidCallback onAddPressed;
  final String? selectedReaction;
  const ChatReactions({
    super.key,
    required this.onEmojiSelected,
    required this.onAddPressed,
    required this.selectedReaction,
  });

  @override
  Widget build(BuildContext context) {
    final emojis = ['👍', '😂', '😍', '😮', '😢', '👏'];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 1.5,
        // vertical: padding,
        vertical: paddingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(middlePadding),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.h,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.purple.shade100, width: 1.5.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...emojis.map(
            (e) => InkWell(
              onTap: () => onEmojiSelected(e),
              borderRadius: BorderRadius.circular(paddingLarge),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingTiny),
                child: selectedReaction == e
                    ? Container(
                        padding: EdgeInsets.all(paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Text(e, style: TextStyle(fontSize: 24.fSize)),
                      )
                    : Text(e, style: TextStyle(fontSize: 24.fSize)),
              ),
            ),
          ),
          InkWell(
            onTap: onAddPressed,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingSmall),
              child: Icon(
                Icons.add_circle_outline,
                size: 26.fSize,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReactionPopupPositioner extends StatefulWidget {
  final Offset bubbleOffset;
  final Size bubbleSize;
  final double verticalGap;
  final void Function(String emoji) onEmojiSelected;
  final VoidCallback onAddPressed;
  final VoidCallback onDismiss;
  final String? selectedReaction;
  const ReactionPopupPositioner({
    super.key,
    required this.bubbleOffset,
    required this.bubbleSize,
    required this.verticalGap,
    required this.onEmojiSelected,
    required this.onAddPressed,
    required this.onDismiss,
    required this.selectedReaction,
  });

  @override
  State<ReactionPopupPositioner> createState() =>
      _ReactionPopupPositionerState();
}

class _ReactionPopupPositionerState extends State<ReactionPopupPositioner> {
  final GlobalKey _popupKey = GlobalKey();
  double? _popupWidth;
  double? _popupHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _popupKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        setState(() {
          _popupWidth = box.size.width;
          _popupHeight = box.size.height;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double left =
        widget.bubbleOffset.dx +
        (widget.bubbleSize.width / 2) -
        ((_popupWidth ?? 0) / 2);
    left = left.clamp(8.0, SizeUtils.width - (_popupWidth ?? 0) - 8.0);
    double top =
        widget.bubbleOffset.dy - (_popupHeight ?? 0) - widget.verticalGap;
    if (top < 8.0) {
      top =
          widget.bubbleOffset.dy +
          widget.bubbleSize.height +
          widget.verticalGap;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: ChatReactions(
                  selectedReaction: widget.selectedReaction,
                  key: _popupKey,
                  onEmojiSelected: widget.onEmojiSelected,
                  onAddPressed: widget.onAddPressed,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final List<String> commonEmojis = [
  '😀',
  '😁',
  '😂',
  '🤣',
  '😃',
  '😄',
  '😅',
  '😆',
  '😉',
  '😊',
  '😍',
  '😘',
  '😗',
  '😚',
  '😋',
  '😜',
  '🤪',
  '😎',
  '🥳',
  '😢',
  '😭',
  '😡',
  '😱',
  '🤔',
  '😐',
  '😴',
  '🤗',
  '👍',
  '👏',
  '🙏',
];
