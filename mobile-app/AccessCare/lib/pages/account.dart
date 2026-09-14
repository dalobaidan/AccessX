import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import '../services/input_service.dart';
import 'dart:async';

//this page is where the user decides whether to signup or login
class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  //to track which option is selected (sign up or login button)
  String selectedButton = 'signup';
  StreamSubscription<String>? _inputSub;

  @override
  void initState() {
    super.initState();

    //these are the functions for the headband navigation
    _inputSub = inputService.listenToPage(
      pageId: 'account',
      isActive: () => ModalRoute.of(context)?.isCurrent ?? false,
      onUp: () {
        Navigator.pop(context); //simply go to the previous page
      },
      onLeft: () {
        _toggleButton();
      },
      onRight: () {
        _toggleButton();
      },
      onDown: () {
        _goNext(); //select it
      },
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  void _toggleButton() {
    //for selection from the headband to focus the selected button
    setState(() {
      selectedButton = selectedButton == 'signup' ? 'login' : 'signup';
    });
  }

  void _goNext() {
    //decides which page to go to based on the selectedbutton (declared up)
    Navigator.pushNamed(
      context,
      selectedButton == 'signup' ? '/sign_up' : '/login_first',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //the appBar is almost identical in all pages which has leading back button (on the far left), here still no home because we didnt reach the dashboard yet
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          //we used our own back button and we declared it as .svg
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            width: 40,
            height: 40,
          ),
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        //to be able to control the size of the progress indicator
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: Image.asset(
              'assets/images/progress_indicator_3.png',
              height: 14,
            ),
          ),
        ),
      ),
      //we chose singleChildScrollView as it prevented the overflow problem that happened when we tried it on different phones if we used Row/column
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              //all images are in the assets/images
              Image.asset('assets/images/logo.png', width: 93, height: 79),
              const SizedBox(height: 10),
              const Text(
                'Choose how to\ncontinue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 65),
              //gesturedetector is used because it makes the images selectable
              GestureDetector(
                onTap: () {
                  if (selectedButton == 'signup') {
                    _goNext();
                  } else {
                    setState(() => selectedButton = 'signup');
                  }
                },
                child: Image.asset(
                  selectedButton == 'signup'
                      ? 'assets/images/signup_focused.png'
                      : 'assets/images/signup.png',
                  width: 330,
                  height: 73,
                ),
              ),
              const SizedBox(height: 28),
              //to make the normal use possible
              GestureDetector(
                onTap: () {
                  if (selectedButton == 'login') {
                    _goNext();
                  } else {
                    setState(() => selectedButton = 'login');
                  }
                },
                //to make the button focused
                child: Image.asset(
                  selectedButton == 'login'
                      ? 'assets/images/login_focused.png'
                      : 'assets/images/login.png',
                  width: 330,
                  height: 73,
                ),
              ),
              const SizedBox(height: 195),
              //this widget is used to indicate whether the iot device is connected or not
              const DeviceStatusImage(width: 351),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
