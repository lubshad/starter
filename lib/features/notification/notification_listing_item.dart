import 'package:flutter/material.dart';

import '../../exporter.dart';
import 'models/notification_model.dart';

class NotificationListingItem extends StatelessWidget {
  const NotificationListingItem({super.key, required this.item});

  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(paddingLarge),
        boxShadow: defaultShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(paddingLarge),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Color(0xff147CBD),
                  size: 24.h,
                ),
                gapLarge,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.dateTime.dateTimeFormat ?? "N/A",
                        style: context.bodySmall.copyWith(
                          color: Color(0xff3C3F4E),
                        ),
                      ),
                      gapSmall,
                      Text(
                        item.title,
                        maxLines: 1,
                        style: context.bodySmall.copyWith(
                          color: Color(0xff3C3F4E),
                        ),
                      ),
                      gapSmall,

                      Text(
                        item.description,
                        maxLines: 2,
                        style: context.bodySmall.copyWith(
                          color: Color(0xff666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
