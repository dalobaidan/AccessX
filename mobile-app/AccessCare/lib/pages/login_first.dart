import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';
import 'auth.dart';

//login page
class LoginFirst extends StatefulWidget {
  const LoginFirst({super.key});

  @override
  State<LoginFirst> createState() => _LoginFirstState();
}

class _LoginFirstState extends State<LoginFirst> {
  final LocalAuthentication _auth = LocalAuthentication();

  //like textfields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  StreamSubscription<String>? _inputSub;

  bool _obscurePassword = true;

  // 0 = Face ID, 1 = Sign Up, 2 = email, 3 = password, 4 = login button
  //we made the faceid first focused so the user directly access it first
  int selectedIndex = 0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'login_first',
      isActive: () => ModalRoute.of(context)?.isCurrent ?? false,
      onUp: () => Navigator.pop(context),
      onLeft: _movePrevious,
      onRight: _moveNext,
      onDown: _selectCurrent,
    );

    // If the user already logged in before and Firebase still has the session,
    // Face ID can be used immediately without typing email/password.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        _loginWithFaceId();
      }
    });
  }

  @override
  void dispose() {
    _inputSub?.cancel();

    _emailController.dispose();
    _passwordController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  // Cycle forward through the 5 interactive elements, wrapping around.
  void _moveNext() {
    setState(() {
      selectedIndex = (selectedIndex + 1) % 5;
    });
  }

  //cycle backward with wrapping/looping
  void _movePrevious() {
    setState(() {
      selectedIndex = (selectedIndex - 1 + 5) % 5;
    });
  }

  //depends on the button then navigates accordingly
  void _selectCurrent() {
    switch (selectedIndex) {
      case 0:
        _loginWithFaceId();
        break;
      case 1:
        Navigator.pushNamed(context, '/sign_up');
        break;
      case 2:
        FocusScope.of(context).requestFocus(_emailFocus);
        break;
      case 3:
        FocusScope.of(context).requestFocus(_passwordFocus);
        break;
      case 4:
        signIn();
        break;
    }
  }

  // Attempts email/password login via Firebase.
  // This is async because Firebase makes a network request to verify credentials.
  Future<void> signIn() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      //check the textfields if empty
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          errorMessage = 'Email and password are required';
        });
        return;
      }

      await Auth().signInWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Login failed';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  // Attempts biometric authentication using the device's Face ID
  // If successful AND a Firebase session exists it navigates to Dashboard.
  Future<void> _loginWithFaceId() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face ID is not available on this device.'),
          ),
        );
        return;
      }

      // This line triggers the system's Face ID
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Use Face ID to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      // If the user cancelled or failed biometric check, didAuthenticate is false.
      if (!didAuthenticate) return;

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please log in once first. After that, Face ID will work as a fast login.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      //this is like an alert or Toast message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Face ID error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool faceIdSelected = selectedIndex == 0;
    final bool signUpSelected = selectedIndex == 1;
    final bool loginSelected = selectedIndex == 4;

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
          'Log In',
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
              'assets/images/progress_indicator_4.png',
              height: 14,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/images/logo.png', width: 93, height: 79),
                const SizedBox(height: 10),
                const Text(
                  'Log In',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/email_textfield.png',
                        width: 354,
                      ),
                      Positioned(
                        left: 45,
                        right: 10,
                        top: 39,
                        bottom: 4,
                        child: TextField(
                          focusNode: _emailFocus,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: Color(0xFF221F1F),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter email',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: Color(0x66221F1F),
                            ),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/password_textfield.png',
                        width: 348,
                      ),
                      Positioned(
                        left: 45,
                        right: 40,
                        top: 38,
                        bottom: 4,
                        child: TextField(
                          focusNode: _passwordFocus,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: Color(0xFF221F1F),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            //hint text to know what to enter
                            hintText: 'Enter password',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              color: Color(0x66221F1F),
                            ),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 45,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              //hide the password like this **
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF9E9E9E),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                //normal user
                GestureDetector(
                  onTap: () async {
                    if (loginSelected) {
                      await signIn();
                    } else {
                      setState(() => selectedIndex = 4);
                    }
                  },
                  child: Image.asset(
                    loginSelected
                        ? 'assets/images/loginBtn_focused.png'
                        : 'assets/images/loginBtn.png',
                    width: 330,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (faceIdSelected) {
                      _loginWithFaceId();
                    } else {
                      setState(() => selectedIndex = 0);
                    }
                  },
                  child: Image.asset(
                    faceIdSelected
                        ? 'assets/images/faceid_selected.png'
                        : 'assets/images/faceid_unselected.png',
                    width: 330,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (signUpSelected) {
                          Navigator.pushNamed(context, '/sign_up');
                        } else {
                          setState(() => selectedIndex = 1);
                        }
                      },
                      //it lets us change the text style smoothly instead of instantly
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: signUpSelected ? 23 : 20,
                          color: signUpSelected
                              ? const Color(0xFF275059)
                              : const Color(0xFF54ADBF),
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
                //iot device status
                const DeviceStatusImage(width: 351),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
