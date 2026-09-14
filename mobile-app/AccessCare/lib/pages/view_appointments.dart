import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/input_service.dart';

class ViewAppointments extends StatefulWidget {
  const ViewAppointments({super.key});

  @override
  State<ViewAppointments> createState() => _ViewAppointmentsState();
}

class _ViewAppointmentsState extends State<ViewAppointments> {
  bool showCancelButton = true;
  bool isLoading = true;

  // These fields mirror the Firebase appointment node structure, they're then populated by _loadAppointment() once Firebase responds
  String doctorName = '';
  String specialty = '';
  String hospital = '';
  String month = '';
  String week = '';
  String day = '';
  String time = '';
  String status = '';

  StreamSubscription<String>? _inputSub;
  bool _isActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    _loadAppointment();

    _inputSub = inputService.listenToPage(
      pageId: 'view_appointments',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(context),
      onDown: _cancelAppointment,
      onLeft: () {},
      onRight: () {},
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  // it reads the user's current appointment from Firebase Realtime Database
  Future<void> _loadAppointment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final uid = user.uid;

      final snapshot = await FirebaseDatabase.instance
          .ref('users/$uid/currentAppointment')
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        if (!mounted) return;

        setState(() {
          doctorName = data['doctorName'] ?? '';
          specialty = data['specialty'] ?? '';
          hospital = data['hospital'] ?? '';
          month = data['month'] ?? '';
          week = data['week'] ?? '';
          day = data['day'] ?? '';
          time = data['time'] ?? '';
          status = data['status'] ?? 'upcoming';

          showCancelButton = status == 'upcoming';
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading appointment: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // updates the appointment's status to (cancelled) in Firebase
  Future<void> _cancelAppointment() async {
    if (!showCancelButton) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final uid = user.uid;

      await FirebaseDatabase.instance
          .ref('users/$uid/currentAppointment')
          .update({'status': 'cancelled'});

      if (!mounted) return;

      setState(() {
        showCancelButton = false;
        status = 'cancelled';
      });

      //like a Toast or alert
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Canceled successfully')));
    } catch (e) {
      debugPrint('Error canceling appointment: $e');
    }
  }

  //to get the dr initials
  String get doctorInitials {
    if (doctorName.trim().isEmpty) return '';

    return doctorName
        .split(' ')
        .where((w) => w.isNotEmpty && w != 'Dr.')
        .map((w) => w[0])
        .take(2)
        .join();
  }

  String get displayDate {
    if (day.isEmpty && month.isEmpty) {
      return 'No date';
    }

    return '$day $month';
  }

  String get displayTime {
    if (time.isEmpty) {
      return 'No time';
    }

    return time;
  }

  bool get hasAppointment {
    return doctorName.isNotEmpty;
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            width: 40,
            height: 40,
          ),
        ),
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _goHome,
            icon: SvgPicture.asset(
              'assets/images/home_icon.svg',
              width: 24.77,
              height: 22,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF54ADBF)),
            )
          : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  //all dimensions/positions are taken from our design on Figma
                  Positioned(
                    left: 36,
                    top: 10,
                    child: SizedBox(
                      width: 329.8,
                      height: 400,
                      child: Image.asset(
                        'assets/images/whiteBackground.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 56,
                    top: 40,
                    child: SizedBox(
                      width: 160,
                      height: 28,
                      child: Image.asset(
                        showCancelButton
                            ? 'assets/images/upcomingAppoitment.png'
                            : 'assets/images/pastAppoitment.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  // If no appointment exists, show a message. if not, show all the appointment details
                  if (!hasAppointment)
                    const Positioned(
                      left: 56,
                      top: 120,
                      right: 56,
                      child: Text(
                        'No appointment booked yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF023859),
                        ),
                      ),
                    )
                  else ...[
                    Positioned(
                      left: 56,
                      top: 85,
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset(
                          'assets/images/pfpBackground.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 74,
                      top: 105,
                      child: Text(
                        doctorInitials,
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 17.3,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 136,
                      top: 90,
                      child: SizedBox(
                        width: 209.8,
                        height: 54,
                        child: Text(
                          doctorName,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 136,
                      top: 150,
                      child: SizedBox(
                        width: 209.8,
                        height: 54,
                        child: Text(
                          specialty,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF7C8AA5),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 136,
                      top: 180,
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: Image.asset(
                          'assets/images/loc_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 156,
                      top: 178,
                      child: SizedBox(
                        width: 168,
                        height: 20,
                        child: Text(
                          hospital,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF7C8AA5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 56,
                      top: 220,
                      child: SizedBox(
                        width: 298.8,
                        height: 72,
                        child: Image.asset(
                          'assets/images/aptDate.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 109,
                      top: 260,
                      child: Text(
                        displayDate,
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A6D8A),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 245.9,
                      top: 260,
                      child: Text(
                        displayTime,
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A6D8A),
                        ),
                      ),
                    ),
                    if (showCancelButton)
                      Positioned(
                        left: 56,
                        top: 315,
                        child: GestureDetector(
                          onTap: _cancelAppointment,
                          child: SizedBox(
                            width: 287,
                            height: 46,
                            child: Image.asset(
                              'assets/images/cancelAppointment_Button.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                  ],
                  Positioned(
                    left: 36,
                    top: 380,
                    child: SizedBox(
                      width: 329.8,
                      height: 380,
                      child: Image.asset(
                        'assets/images/whiteBackground.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 56,
                    top: 410,
                    child: SizedBox(
                      width: 160,
                      height: 28,
                      child: Image.asset(
                        'assets/images/pastAppoitment.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 56,
                    top: 460,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Image.asset(
                        'assets/images/pfpBackground.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 74,
                    top: 480,
                    child: Text(
                      'AA',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 17.3,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 136,
                    top: 470,
                    child: SizedBox(
                      width: 209.8,
                      height: 54,
                      child: Text(
                        'Dr. Ahmed Alotaibi',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 136,
                    top: 500,
                    child: SizedBox(
                      width: 209.8,
                      height: 54,
                      child: Text(
                        'Neurology',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF7C8AA5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 136,
                    top: 530,
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: Image.asset(
                        'assets/images/loc_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 156,
                    top: 527,
                    child: SizedBox(
                      width: 168,
                      height: 20,
                      child: Text(
                        'Dr. Alhabib-Takhassusi',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF7C8AA5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 56,
                    top: 570,
                    child: SizedBox(
                      width: 298.8,
                      height: 72,
                      child: Image.asset(
                        'assets/images/aptDate.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 109,
                    top: 610,
                    child: Text(
                      '17/11/2025',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5A6D8A),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 245.9,
                    top: 610,
                    child: Text(
                      '9:30 AM',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5A6D8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
