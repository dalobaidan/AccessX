import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';
import 'appointments.dart';
import 'contacts.dart';
import 'prescriptions.dart';
import 'profile.dart';

//our MAIN page it contains the appointments, contacts, prescriptions, and profile
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // focusedIndex tracks which of the 4 buttons is currently highlighted.
  // 0=Appointments, 1=Contacts, 2=Prescriptions, 3=Profile
  int focusedIndex = 0;
  String userName = '';

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

    _loadUserData();

    _inputSub = inputService.listenToPage(
      pageId: 'dashboard',
      isActive: () => _isActive,
      onLeft: () {
        // Wrap backward: going left from index 0 to index 3
        setState(() {
          focusedIndex = (focusedIndex - 1 + 4) % 4;
        });
      },
      onRight: () {
        // Wrap forward: going right from index 3 to index 0
        setState(() {
          focusedIndex = (focusedIndex + 1) % 4;
        });
      },
      onDown: _goToFocusedScreen,
      onUp: () {}, // up doesnt have a functionality here
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  // Fetches the logged-in user's name from Firebase Realtime Database.
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final uid = user.uid;
      final DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid');
      // We don't need live updates for the user's name, a single fetch is enough
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        if (!mounted) return;

        setState(() {
          userName = data['name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Navigates to the screen corresponding to the currently focused button.
  void _goToFocusedScreen() {
    switch (focusedIndex) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Appointments()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Contacts()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Prescriptions()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Profile()));
        break;
    }
  }

  //touch tap handler, focuses the tapped button on first tap,
  // then navigates on second tap (same "focus then activate" logic as other screens)
  void _handleTap(int index) {
    if (focusedIndex == index) {
      _goToFocusedScreen();
    } else {
      setState(() {
        focusedIndex = index;
      });
    }
  }

  // Builds one of the four dashboard buttons as a Positioned widget inside
  Widget _buildSelectableButton({
    required int index,
    required double left,
    required double top,
    required String selectedImagePath,
    required String unselectedImagePath,
    required VoidCallback onTap,
  }) {
    final bool isFocused = focusedIndex == index;

    return Positioned(
      left: isFocused ? left - 6 : left,
      top: isFocused ? top - 6 : top,
      child: GestureDetector(
        onTap: onTap,
        //animatedcontainer allows for nice design and shadows
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isFocused ? 201.5 : 189.5,
          height: isFocused ? 167.26 : 155.26,
          child: Image.asset(
            isFocused ? selectedImagePath : unselectedImagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //appBar design is the same but it contains the logout button instead that navigate to the account page
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/account',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Color(0xFF023859), size: 28),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 10,
              child: SizedBox(
                width: 402,
                height: 145,
                child: Image.asset(
                  'assets/images/dashboard.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 145,
              top: 40,
              child: Text(
                userName.isEmpty ? 'Loading...' : userName,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C3B63),
                ),
              ),
            ),
            const Positioned(
              left: -4,
              top: 200,
              right: 0,
              child: Center(
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02385A),
                  ),
                ),
              ),
            ),
            //appointment button
            _buildSelectableButton(
              index: 0,
              left: 14,
              top: 280,
              selectedImagePath: 'assets/images/appointments_button.png',
              unselectedImagePath: 'assets/images/appointment_unselected.png',
              onTap: () => _handleTap(0),
            ),

            //contacts button
            _buildSelectableButton(
              index: 1,
              left: 197.91,
              top: 280,
              selectedImagePath: 'assets/images/contacts_button.png',
              unselectedImagePath: 'assets/images/contacts_unselected.png',
              onTap: () => _handleTap(1),
            ),

            //prescriptions button
            _buildSelectableButton(
              index: 2,
              left: 14,
              top: 450,
              selectedImagePath: 'assets/images/prescriptions_button.png',
              unselectedImagePath: 'assets/images/perscription_unselected.png',
              onTap: () => _handleTap(2),
            ),

            //profile button
            _buildSelectableButton(
              index: 3,
              left: 197.91,
              top: 450,
              selectedImagePath: 'assets/images/profile_button.png',
              unselectedImagePath: 'assets/images/profile_unselected.png',
              onTap: () => _handleTap(3),
            ),

            //to check the iot device status
            Positioned(
              left: 23,
              top: 670,
              child: SizedBox(
                  width: 351, height: 37, child: DeviceStatusImage(width: 351)),
            ),
          ],
        ),
      ),
    );
  }
}
