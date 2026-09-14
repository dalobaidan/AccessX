import 'package:flutter/material.dart';
import 'dart:async';
import '../services/input_service.dart';

class DeviceStatusImage extends StatefulWidget {
  final double? width;
  const DeviceStatusImage({super.key, this.width});

  @override
  State<DeviceStatusImage> createState() => _DeviceStatusImageState();
}

class _DeviceStatusImageState extends State<DeviceStatusImage> {
  late String _status;
  late StreamSubscription<String> _sub;

  @override
  void initState() {
    super.initState();
    _status = inputService.deviceStatus;
    _sub = inputService.statusStream.listen((s) {
      if (mounted) setState(() => _status = s);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //it just changed the image of the device status to either connected or disconnected
    return Image.asset(
      _status == 'connected'
          ? 'assets/images/device_connected.png'
          : 'assets/images/device_disconnected.png',
      width: widget.width,
    );
  }
}
