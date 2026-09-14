import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

const bool kSimulationEnabled = false;
const Duration kSimulationDelay = Duration(seconds: 2);

class InputService {
  static final InputService _instance = InputService._internal();

  factory InputService() => _instance;

  InputService._internal();

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  // device status stream- for showing connected/disconnected
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  Stream<String> get inputStream => _controller.stream;
  Stream<String> get statusStream => _statusController.stream;

  String deviceStatus = 'disconnected';

  // called by mqtt_service when a gesture arrives
  void inject(String gesture) {
    _controller.add(gesture);
  }

  // called by mqtt_service when device status arrives
  void updateDeviceStatus(String status) {
    deviceStatus = status;
    _statusController.add(status);
  }

  //lets a page listen to gesture events, the page only reacts if isActive() says this page is currently showing
  StreamSubscription<String> listenToPage({
    required String pageId,
    required bool Function() isActive,
    VoidCallback? onUp,
    VoidCallback? onDown,
    VoidCallback? onLeft,
    VoidCallback? onRight,
  }) {
    return inputStream.listen((input) {
      if (!isActive()) return;

      if (input == 'up') {
        onUp?.call();
      } else if (input == 'down') {
        onDown?.call();
      } else if (input == 'left') {
        onLeft?.call();
      } else if (input == 'right') {
        onRight?.call();
      }
    });
  }

  //we added this to check first if the idea of gestures work before we connect our app to the Broker
  Future<void> startSimulation() async {
    if (!kSimulationEnabled) return;

    final String jsonString = await rootBundle.loadString(
      'assets/simulation.json',
    );

    final Map<String, dynamic> data = json.decode(jsonString);
    final List<String> moves = List<String>.from(data['moves']);

    for (final move in moves) {
      await Future.delayed(kSimulationDelay);
      _controller.add(move);
    }
  }

  void dispose() {
    _controller.close();
    _statusController.close();
  }
}

final inputService = InputService();
