import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Profile data fields: it starts empty then gets populated by _loadProfileData()
  String fullName = '';
  String email = '';
  String phone = '';

  bool isLoading = true; // true while Firebase fetch is in flight

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

    _loadProfileData();

    _inputSub = inputService.listenToPage(
      pageId: 'profile',
      isActive: () => _isActive,
      onUp: () =>
          Navigator.pop(context), //back to the previous page (dashboard)
      onDown: _goToLabResults, // navigate forward to lab results
      onLeft: () {}, // no left/right navigation on this page
      onRight: () {},
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final uid = user.uid;
      final DatabaseReference ref = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        if (!mounted) return;

        setState(() {
          fullName = data['name'] ?? '';
          email = data['email'] ?? user.email ?? '';
          phone = data['phone'] ?? '';
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          fullName = '';
          email = user.email ?? '';
          phone = '';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // we return (Not available) in case of empty values
  String _displayValue(String value) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }
    return value;
  }

  void _goToLabResults() {
    Navigator.pushNamed(context, '/lab_results');
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
      //same appBar
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
          'My Profile',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
          child: Column(
            children: [
              Image.asset('assets/images/myProfileImage.png', width: 148),
              const SizedBox(height: 18),
              const Text(
                'Profile Overview',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF0B436E),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(color: Color(0xFF54ADBF)),
                )
              //else ... takes all (multiple) widgets
              else ...[
                ProfileDetailRow(
                  icon: Icons.person_outline,
                  label: 'Name:',
                  value: _displayValue(fullName),
                ),
                const SizedBox(height: 18),
                ProfileDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email:',
                  value: _displayValue(email),
                ),
                const SizedBox(height: 18),
                ProfileDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number:',
                  value: _displayValue(phone),
                ),
              ],
              const SizedBox(height: 80),
              const StatusBanner(
                icon: Icons.check_circle,
                label: 'Lab results are ready',
                description: '',
              ),
              const SizedBox(height: 14),
              ImageActionButton(
                imagePath: 'assets/images/view_lab_results_button.png',
                onPressed: _goToLabResults,
              ),
              const SizedBox(height: 90),
              const DeviceStatusImage(width: 351),
            ],
          ),
        ),
      ),
    );
  }
}

// A single row displaying an icon, a label ("Name:"), and its value
class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0B436E), size: 28),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF0B436E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF184C7A),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class StatusBanner extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const StatusBanner({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 348,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF54ADBF), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF0B436E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageActionButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const ImageActionButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        imagePath,
        width: 330,
        height: 64,
        fit: BoxFit.contain,
      ),
    );
  }
}
