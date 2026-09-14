import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_project/widgets/device_status.dart';
import '../services/input_service.dart';
import 'dart:async';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool createSelected = false;

  int selectedIndex = 0;
  StreamSubscription<String>? _inputSub;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'sign_up',
      isActive: () => ModalRoute.of(context)?.isCurrent ?? false,
      onUp: () {
        Navigator.pop(context);
      },
      onRight: () {
        _moveNext();
      },
      onLeft: () {
        _movePrevious();
      },
      onDown: () {
        _selectCurrent();
      },
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();

    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  void _moveNext() {
    setState(() {
      if (selectedIndex < 4) {
        selectedIndex++;
      }
      createSelected = selectedIndex == 4;
    });
  }

  void _movePrevious() {
    setState(() {
      if (selectedIndex > 0) {
        selectedIndex--;
      }
      createSelected = selectedIndex == 4;
    });
  }

  void _selectCurrent() {
    if (selectedIndex == 0) {
      FocusScope.of(context).requestFocus(_fullNameFocus);
    } else if (selectedIndex == 1) {
      FocusScope.of(context).requestFocus(_emailFocus);
    } else if (selectedIndex == 2) {
      FocusScope.of(context).requestFocus(_phoneFocus);
    } else if (selectedIndex == 3) {
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (selectedIndex == 4) {
      signUp();
    }
  }

  Future<void> signUp() async {
    try {
      final fullName = _fullNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      if (fullName.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          password.isEmpty) {
        setState(() {
          errorMessage = 'Please fill in all fields';
        });
        return;
      }

      if (!email.contains('@')) {
        setState(() {
          errorMessage = 'Please enter a valid email';
        });
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      await FirebaseDatabase.instance.ref('users/$uid').set({
        'name': fullName,
        'email': email,
        'phone': phone,
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/signup_complete');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Signup failed';
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Widget _focusedWrapper({required bool isSelected, required Widget child}) {
    return child;
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
          'Sign Up',
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Image.asset('assets/images/logo.png', width: 93, height: 79),

              const SizedBox(height: 10),

              const Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // Full Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _focusedWrapper(
                  isSelected: selectedIndex == 0,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/fullName_textfield.png',
                        width: 354,
                        height: 75,
                      ),
                      Positioned(
                        left: 45,
                        right: 10,
                        top: 40,
                        bottom: 4,
                        child: TextField(
                          focusNode: _fullNameFocus,
                          controller: _fullNameController,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Color(0xFF221F1F),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter first and last name',
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
              ),

              const SizedBox(height: 12),

              // Email
              Padding(
                padding: const EdgeInsets.only(right: 4, top: 5),
                child: _focusedWrapper(
                  isSelected: selectedIndex == 1,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/email_textfield.png',
                        width: 350,
                      ),
                      Positioned(
                        left: 46,
                        right: 10,
                        top: 40,
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
              ),

              const SizedBox(height: 12),

              // Phone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _focusedWrapper(
                  isSelected: selectedIndex == 2,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/phoneNumber_textfield.png',
                        width: 354,
                        height: 75,
                      ),
                      Positioned(
                        left: 145,
                        right: 10,
                        top: 40,
                        bottom: 4,
                        child: TextField(
                          focusNode: _phoneFocus,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: Color(0xFF221F1F),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter phone no.',
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
              ),

              const SizedBox(height: 12),

              // Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _focusedWrapper(
                  isSelected: selectedIndex == 3,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/password_textfield.png',
                        width: 348,
                        height: 75,
                      ),
                      Positioned(
                        left: 46,
                        right: 40,
                        top: 40,
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

              const SizedBox(height: 20),

              // Create Account Button
              GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedIndex = 4;
                    createSelected = true;
                  });

                  await signUp();
                },
                child: Image.asset(
                  selectedIndex == 4
                      ? 'assets/images/createAccountBtn_focused.png'
                      : 'assets/images/createAccountBtn.png',
                  width: 330,
                  height: 64,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Have an account?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login_first');
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFF54ADBF),
                      ),
                    ),
                  ),
                ],
              ),

              const DeviceStatusImage(width: 351),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
