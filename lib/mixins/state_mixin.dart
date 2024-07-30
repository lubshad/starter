import 'package:flutter/material.dart';
import 'event_listener.dart';

mixin StateFullMixin<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
      EventListener.i.sendEvent(Event(eventType: EventType.updateState));
    }
  }
}
