import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import '../services/input_service.dart';
import 'dart:async';

//a starter screen to welcome the user
class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  StreamSubscription<String>? _inputSub;

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'welcome',
      isActive: () => ModalRoute.of(context)?.isCurrent ?? false,
      onDown: () {
        Navigator.pushNamed(context, '/tutorial');
      },
    );

    inputService.startSimulation();
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
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
          'Welcome',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: Image.asset(
              'assets/images/progress_indicator_1.png',
              height: 14,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Image.asset('assets/images/logo.png', width: 147, height: 125),
            const SizedBox(height: 40),
            const Text(
              'Welcome',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 55,
                fontWeight: FontWeight.w700,
                color: Color(0xFF003756),
              ),
            ),
            const SizedBox(height: 3),
            Image.asset(
              'assets/images/welcome_line.png',
              width: 156,
              height: 6,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your device is ready',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const Text(
              'Nod to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 25,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7890),
              ),
            ),
            const SizedBox(height: 30),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/tutorial');
                },
                child: Image.asset(
                  'assets/images/continue_focused.png',
                  width: 323,
                  height: 64,
                ),
              ),
            ),
            const SizedBox(height: 45),
            //to show device status (connected or disconnected)
            const DeviceStatusImage(width: 351),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
