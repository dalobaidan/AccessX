import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';

//this acts like a splash screen where after the user books an appointment it displays a summary of the booking with confirmation
class Confirmation extends StatefulWidget {
  final String doctorName;
  final String hospital;
  final String specialty;
  final String month;
  final String week;
  final String day;
  final String time;

  //we need the data to know which data was selected, like which dr, day, time etc..
  const Confirmation({
    super.key,
    required this.doctorName,
    required this.hospital,
    required this.specialty,
    required this.month,
    required this.week,
    required this.day,
    required this.time,
  });

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  StreamSubscription<String>? _inputSub;
  Timer? _timer; // directly go to Dashboard after 5 seconds
  bool _hasNavigated = false;
  bool _isActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    _saveAppointment();

    // Any gesture dismisses the confirmation screen and goes home.
    _inputSub = inputService.listenToPage(
      pageId: 'confirmation',
      isActive: () => _isActive,
      onUp: _goToDashboard,
      onDown: _goToDashboard,
      onLeft: _goToDashboard,
      onRight: _goToDashboard,
    );

    //stay for 5 seconds
    _timer = Timer(
      const Duration(seconds: 5),
      _goToDashboard,
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    _timer
        ?.cancel(); // cancels the 5 second countdown if widget is removed early
    super.dispose();
  }

  //we are saving the appointment to be able to see it in the view appointment button
  Future<void> _saveAppointment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('No user logged in. Appointment not saved.');
        return;
      }

      final uid = user.uid;

      await FirebaseDatabase.instance.ref('users/$uid/currentAppointment').set({
        'doctorName': widget.doctorName,
        'hospital': widget.hospital,
        'specialty': widget.specialty,
        'month': widget.month,
        'week': widget.week,
        'day': widget.day,
        'time': widget.time,
        'status': 'upcoming',
        'createdAt': DateTime.now().toIso8601String(),
      });

      debugPrint('Appointment saved successfully');
    } catch (e) {
      debugPrint('Error saving appointment: $e');
    }
  }

  // Clears the entire navigation stack and returns to Dashboard
  void _goToDashboard() {
    if (_hasNavigated) return;

    _hasNavigated = true;
    _inputSub?.cancel();
    _timer?.cancel();

    Future.microtask(() {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    });
  }

  //Splits "Dr. John Smith" onto two lines for large font display
  String get formattedDoctorName {
    if (!widget.doctorName.contains(' ')) return widget.doctorName;

    return '${widget.doctorName.substring(0, widget.doctorName.lastIndexOf(' '))}\n'
        '${widget.doctorName.substring(widget.doctorName.lastIndexOf(' ') + 1)}';
  }

  //just to take the initials of the dr name to make it more pleasant looking
  String get doctorInitials {
    return widget.doctorName
        .split(' ')
        .where((w) => w.isNotEmpty && w != 'Dr.')
        .map((w) => w[0])
        .take(2)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //we didnt add appBar as its only a splash
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/confirmation_check.png',
                  width: 112,
                  height: 112,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appointment Booked\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF023859),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 377,
                  height: 278,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/confirmation_card.png',
                        width: 377,
                        height: 278,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: 35,
                        left: 45,
                        right: 24,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF54ACBF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  doctorInitials,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDoctorName,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF023859),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.specialty,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF023859),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/location_icon.png',
                                        width: 14,
                                        height: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.hospital,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF4093A4),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //all positions are taken from our Figma design
                      Positioned(
                        bottom: 50,
                        left: 45,
                        right: 24,
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/datetime_box.png',
                              width: 290,
                              height: 72,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 16,
                              right: 0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/date_icon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF65758B),
                                        ),
                                      ),
                                      Text(
                                        '${widget.day} ${widget.month}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF023859),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  Image.asset(
                                    'assets/images/time_icon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF65758B),
                                        ),
                                      ),
                                      Text(
                                        widget.time,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF023859),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
              //iot device status
              Center(
                child: DeviceStatusImage(width: 351),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
