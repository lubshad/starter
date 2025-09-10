import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'shimwrapper.dart';
import 'user_avatar.dart';
import '../exporter.dart';

class PersonTile extends StatelessWidget {
  final bool hasSubTitle;
  final String? name;
  final String? department;
  final String? company;
  final bool? hasDivider;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Widget? trailing;
  final bool addMediaUrl;
  const PersonTile({
    super.key,
    this.hasDivider = true,
    this.hasSubTitle = false,
    this.name,
    this.department,
    this.company,
    this.imageUrl,
    this.onTap,
    this.borderColor,
    this.trailing,
    this.addMediaUrl = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 25.w),
          onTap: onTap,
          leading: UserAvatar(
            bgColor: randomColors,
            size: 40.w,
            imageUrl: imageUrl,
            username: name ?? "",
            borderColor: borderColor,
            addMediaUrl: addMediaUrl,
          ),
          title: Text(
            name ?? 'N/A',
            style: context.montserrat50017.copyWith(fontSize: 13.sp),
          ),
          subtitle: hasSubTitle == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (department != null)
                      Text(department!, style: context.bodySmall),

                    if (company != null)
                      Text(company!, style: context.bodySmall),
                  ],
                )
              : null,
          trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 15.sp),
        ),
        Visibility(
          visible: hasDivider!,
          child: Divider(color: Color(0xFFF5F5F5), thickness: 2, height: 1),
        ),
      ],
    );
  }
}


class PersonListingTileShimmer extends StatelessWidget {
  const PersonListingTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: padding,
        horizontal: paddingSmall,
      ),
      child: Row(
        children: [
          Shimwrapper(
                child: Container(
                  width: 50.h,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(end: 1.05, duration: 500.ms),

          gapLarge,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimwrapper(
                      child: Container(
                        height: 14.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fade(duration: 200.ms)
                    .slideX(begin: 1, duration: 200.ms),

                gap,
                Shimwrapper(
                      child: Container(
                        height: 10.h,
                        width: ScreenUtil().screenWidth * 0.4,
                        color: Colors.white,
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fade(duration: 200.ms)
                    .slideX(begin: 1, duration: 200.ms),
              ],
            ),
          ),
          gapLarge,
          Shimwrapper(
                child: Container(
                  width: 20.h,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.h),
                  ),
                ),
              )
              .animate(delay: 200.ms)
              .fade(duration: 200.ms)
              .slideY(begin: -1, duration: 200.ms),
        ],
      ),
    );
  }
}
