import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../exporter.dart';
import '../agora_rtm_service.dart';

class ReplyMessageWidget extends StatelessWidget {
  final ReplyMessageData replyData;
  final bool isMe;
  final VoidCallback? onTap;

  const ReplyMessageWidget({
    super.key,
    this.onTap,
    required this.replyData,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: paddingSmall),
        padding: EdgeInsets.all(paddingSmall),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withAlpha(0.2.alpha)
              : Colors.black.withAlpha(0.1.alpha),
          borderRadius: BorderRadius.circular(paddingSmall),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.white : Color(0xFF832FB7),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              replyData.senderName,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isMe ? Colors.white : Color(0xFF832FB7),
                fontSize: 11.sp,
              ),
            ),
            Gap(2.h),
            Text(
              replyData.content,
              style: context.bodySmall.copyWith(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 11.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
