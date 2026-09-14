import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'input_service.dart';

class MqttService {
  // This holds the MQTT client when we have one
  // If it's null, it means we're not connected yet or the connection failed.
  MqttServerClient? _client;

  // This listens for incoming MQTT messages
  // We keep it here so we can cancel it later when disconnecting
  StreamSubscription? _messagesSub;

  // Simple variable just to know if MQTT is currently connected.
  bool _isConnected = false;

  static const _lanChannel = MethodChannel('com.accesscare/lan_permission');

  Future<void> connect(String brokerIp) async {
    // On iOS, we need to trigger the Local Network permission first.
    // Normal Dart sockets might fail silently if the permission was never asked for
    if (Platform.isIOS) {
      try {
        await _lanChannel.invokeMethod<void>('prime', brokerIp);

        // Small delay to give iOS time to show/handle the permission check.

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (_) {}
    }

    // Create the client locally first.
    // We only save it into _client after the connection succeeds
    MqttServerClient? c;
    try {
      c = MqttServerClient.withPort(
        brokerIp,
        'flutter_${DateTime.now().millisecondsSinceEpoch}',
        1883,
      );

      // Basic MQTT setup.

      c.useWebSocket = false;
      c.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      c.keepAlivePeriod = 20;
      c.autoReconnect = false;
      c.logging(on: false);

      // This runs when MQTT disconnects, (the device status bottom area change to disconnected)
      c.onDisconnected = () {
        _isConnected = false;
        inputService.updateDeviceStatus('disconnected');
        print('MQTT DISCONNECTED');
      };

      // This runs when MQTT connects successfully.
      c.onConnected = () {
        _isConnected = true;
        print('MQTT CONNECTED');

        // Start listening to gesture and status messages from the headband.
        c!.subscribe('accessx/headband/gesture', MqttQos.atLeastOnce);
        c.subscribe('accessx/headband/status', MqttQos.atLeastOnce);
      };

      // we create the MQTT connection message and this gives the client a unique ID and starts a clean session
      final connMsg = MqttConnectMessage()
          .withClientIdentifier(
              'flutter_${DateTime.now().millisecondsSinceEpoch}')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      c.connectionMessage = connMsg;

      await c.connect();

      if (c.connectionStatus?.state == MqttConnectionState.connected) {
        _client = c;
        _messagesSub = c.updates!.listen(_onMessage);
      } else {
        // Connection did not work, so close it properly.
        print('MQTT CONNECTION FAILED: ${c.connectionStatus}');
        c.disconnect();
      }
    } catch (e) {
      print('MQTT FATAL ERROR: $e');
      //if connection fails halfway, still disconnect the client.
      try {
        c?.disconnect();
      } catch (_) {}
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>> messages) {
    try {
      final message = messages[0].payload as MqttPublishMessage;

      // Convert the message payload from bytes into a readable string.

      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      final topic = messages[0].topic;

      print('MQTT RECEIVED: topic=$topic payload=$payload');

      // Convert the JSON text into a Dart map.
      final Map<String, dynamic> data = jsonDecode(payload);

      if (topic == 'accessx/headband/gesture') {
        // Read the gesture value and clean it up.
        final String gesture = (data['gesture'] ?? '').toString().toLowerCase();
        print('GESTURE INJECTED: $gesture');
        if (gesture.isNotEmpty && gesture != 'none') {
          inputService.inject(gesture);
        }
      } else if (topic == 'accessx/headband/status') {
        final String status = data['device_status'] ?? '';
        print('STATUS UPDATE: $status');
        inputService.updateDeviceStatus(status);
      }
    } catch (e) {
      print('MQTT MESSAGE ERROR: $e');
    }
  }

  bool get isConnected => _isConnected;

  void disconnect() {
    // Stop listening to MQTT messages
    _messagesSub?.cancel();
    _messagesSub = null;
    final c = _client;
    _client = null;
    _isConnected = false;
    //done, then close the connection safely
    try {
      c?.disconnect();
    } catch (e) {
      print('MQTT DISCONNECT ERROR: $e');
    }
  }
}

final MqttService mqttService = MqttService();
