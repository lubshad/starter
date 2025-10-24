// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../exporter.dart';
import '../features/profile_screen/common_controller.dart';
import '../mixins/event_listener.dart';
import 'swipe_button.dart';

class CheckinCheckoutButton extends StatefulWidget {
  const CheckinCheckoutButton({super.key});

  @override
  State<CheckinCheckoutButton> createState() => _CheckinCheckoutButtonState();
}

class _CheckinCheckoutButtonState extends State<CheckinCheckoutButton>
    with EventListenerMixin {
  @override
  initState() {
    super.initState();
    allowedEvents = [EventType.resumed, EventType.refresh];
  }

  @override
  dispose() {
    disposeEventListener();
    super.dispose();
  }

  bool checkedIn = false;

  ValueNotifier<DateTime> lastSwipe = ValueNotifier(serverUtcTime);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([CommonController.i, lastSwipe]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withAlpha(25), Colors.white],
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: paddingXL,
            vertical: paddingLarge,
          ),
          child: SwipeButton.expand(
            onSwipe: () {},
            height: ScreenUtil().deviceType(context) == DeviceType.tablet
                ? ScreenUtil().screenWidth * .1
                : 56,
            elevationThumb: 5,
            elevationTrack: 10,
            trackElevationColor: checkedIn
                ? Colors.red.withAlpha(50)
                : Colors.green.withAlpha(50),
            activeTrackColor: LinearGradient(
              colors: checkedIn
                  ? [Color(0xffD31A5D), Color(0xffE3543F), Color(0xffF59120)]
                  : [Color(0xff5BAE72), Color(0xff5CB274), Color(0xff85DA9D)],
            ),
            activeThumbColor: Colors.white,
            thumbPadding: EdgeInsets.all(paddingTiny),
            thumb: Icon(
              Icons.keyboard_double_arrow_right_rounded,
              color: checkedIn ? Colors.red : Color(0xff5BB073),
            ),
            child: Text(
              (checkedIn ? "Swipe to Check-Out" : "Swipe to Check-in")
                  .toUpperCase(),
              style: context.montserrat60015.copyWith(color: Colors.white),
            ),
          ).animate().fadeIn().slideY(begin: .1),
        );
      },
    );
  }
}
