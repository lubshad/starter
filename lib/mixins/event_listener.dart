// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';

class Event {
  final EventType eventType;
  final dynamic data;
  Event({
    required this.eventType,
    this.data, 
  });
}

enum EventType { tagUpdate, updateState, notification, changeVideo, videoEnd , resumed}

class EventListener {
  EventListener._private();

  static EventListener? _instance;

  static EventListener get i {
    _instance ??= EventListener._private();
    return _instance!;
  }

  final _controller = StreamController<Event>.broadcast();

  Stream<Event> get eventStream => _controller.stream;

  void sendEvent(Event event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

mixin EventListenerMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<Event>? subscription;

  List<EventType> allowedEvents = [];

  listenForEvents(Function(Event) callback) {
    subscription = EventListener.i.eventStream.listen((event) {
      callback(event);
    });
  }

  disposeEventListener() {
    subscription?.cancel();
  }
}
