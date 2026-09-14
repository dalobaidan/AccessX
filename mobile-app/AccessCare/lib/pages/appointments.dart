import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';

//this page is used to view or create appointments/its logic is similar to account page
class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  String selectedButton = 'view';
  StreamSubscription<String>? _inputSub;
  bool _isActive = false;

  //either the user view their appointments or book a new one
  final List<String> _options = ['view', 'book'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if this screen is the one currently showing, if yes, _isActive becomes true if not, or if Flutter can't find the route, it becomes false
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    //listen to the gestures from iot
    _inputSub = inputService.listenToPage(
      pageId: 'appointments',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(context),
      onLeft: _movePrevious,
      onRight: _moveNext,
      onDown: _confirmSelection,
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  //similar logic in all pages
  void _movePrevious() {
    setState(() {
      final i = _options.indexOf(selectedButton);
      //so it loops back
      selectedButton = _options[(i - 1 + _options.length) % _options.length];
    });
  }

  void _moveNext() {
    setState(() {
      final i = _options.indexOf(selectedButton);
      selectedButton = _options[(i + 1) % _options.length];
    });
  }

  void _confirmSelection() {
    if (selectedButton == 'view') {
      Navigator.pushNamed(context, '/view_appointments');
    } else {
      Navigator.pushNamed(context, '/specialities');
    }
  }

  //to go back to dashboard
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
      //same app bar but we have the home button that goes back to the dashboard
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
      //singlechildscrollview to prevent overflow error
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'What would you like to do today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF02385A),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Choose how to\ncontinue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF02385A),
                ),
              ),
              const SizedBox(height: 80),
              //gesturedetector to make the image clickable
              GestureDetector(
                onTap: () {
                  if (selectedButton == 'view') {
                    _confirmSelection();
                  } else {
                    setState(() => selectedButton = 'view');
                  }
                },
                child: Image.asset(
                  selectedButton == 'view'
                      ? 'assets/images/view_button2.png'
                      : 'assets/images/view_button.png',
                  width: 330,
                  height: 73,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                //normal users here
                onTap: () {
                  if (selectedButton == 'book') {
                    _confirmSelection();
                  } else {
                    setState(() => selectedButton = 'book');
                  }
                },
                child: Image.asset(
                  selectedButton == 'book'
                      ? 'assets/images/book_button2.png'
                      : 'assets/images/book_button.png',
                  width: 330,
                  height: 73,
                ),
              ),
              const SizedBox(height: 245),
              //iot device status
              const DeviceStatusImage(width: 351),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
