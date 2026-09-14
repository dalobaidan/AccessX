import 'package:flutter/material.dart';
import 'welcome.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

//the first ever screen once the app starts that has our logo
class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    //its like a splash for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Background image in bottom-left
          Positioned(
            left: -20,
            bottom: 1,
            child: Image.asset('assets/images/background_logo.png', width: 370),
          ),

          // Center logo + text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 130),
                const Text(
                  'AccessCare',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF003756),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
