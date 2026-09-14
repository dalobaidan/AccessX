import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';

class LabResults extends StatefulWidget {
  const LabResults({super.key});

  @override
  State<LabResults> createState() => _LabResultsState();
}

class _LabResultsState extends State<LabResults> {
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

    _inputSub = inputService.listenToPage(
      pageId: 'lab_results',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(
          context), //this page is for show only so no other navigation other than going back
      onDown: () {},
      onLeft: () {},
      onRight: () {},
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
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
      //same appBar that contains the back and home buttons
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
          'Lab Results',
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
      //to avoid overflow
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Results',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF023859),
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/results_1.png',
                width: 350,
                height: 200,
              ),
              Image.asset(
                'assets/images/results_2.png',
                width: 350,
                height: 220,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Past Results',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF023859),
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/results_3.png',
                width: 350,
                height: 200,
              ),
              //to check the iot device status
              const DeviceStatusImage(width: 351),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
