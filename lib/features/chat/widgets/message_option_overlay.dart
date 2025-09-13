import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agora_chat_uikit/sdk_service/chat_sdk_service.dart';

import '../../../exporter.dart';

class MessageOptionsOverlay extends StatelessWidget {
  final Offset position;
  final bool isMe;
  final MessageType messageType;
  final Function(String) onOptionSelected;
  final VoidCallback onDismiss;

  const MessageOptionsOverlay({
    super.key,
    required this.position,
    required this.isMe,
    required this.messageType,
    required this.onOptionSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate menu position to avoid overflow
    final menuWidth = 150.0;
    final menuHeight = _getMenuHeight();

    double left = position.dx;
    double top = position.dy;

    // Adjust position if menu would overflow
    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 16;
    }
    if (top + menuHeight > screenSize.height) {
      top = position.dy - menuHeight - 16;
    }

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(color: Colors.black.withAlpha(0.2.alpha)),
              ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut),
              Positioned(
                    left: left,
                    top: top,
                    child: GestureDetector(
                      onTap: () {},
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: menuWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _buildMenuItems(context),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: Offset(0.8, 0.8),
                    end: Offset(1.0, 1.0),
                    duration: 250.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 200.ms, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final menuItems = <Widget>[];
    if (messageType == MessageType.TXT) {
      menuItems.add(
        _buildMenuItem(
          context: context,
          icon: Icons.copy,
          text: 'Copy',
          value: 'copy',
          isFirst: true,
          isLast: false,
        ),
      );
    }

    menuItems.add(
      _buildMenuItem(
        context: context,
        icon: Icons.reply,
        text: 'Reply',
        value: 'reply',
        isFirst: messageType != MessageType.TXT,
        isLast: false,
      ),
    );

    // if (isMe) {
    menuItems.add(
      _buildMenuItem(
        context: context,
        icon: Icons.delete_outline,
        text: 'Delete',
        value: 'delete',
        isFirst: false,
        isLast: true,
        isDestructive: true,
      ),
    );
    // }

    return menuItems;
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String value,
    required bool isFirst,
    required bool isLast,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOptionSelected(value),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(12) : Radius.zero,
          bottom: isLast ? Radius.circular(12) : Radius.zero,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isDestructive
                        ? Colors.red
                        : Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: 12),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDestructive
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMenuHeight() {
    int itemCount = 1; // Reply is always available
    if (messageType == MessageType.TXT) itemCount++; // Copy
    if (isMe) itemCount++; // Delete

    return itemCount * 44.0; // 44 is approximate height per item
  }
}
