import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';

//prescriptions page
class Prescriptions extends StatefulWidget {
  const Prescriptions({super.key});

  @override
  State<Prescriptions> createState() => _PrescriptionsState();
}

class _PrescriptionsState extends State<Prescriptions> {
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
      pageId: 'prescriptions',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(context),
      onDown: () => _handleSendRefillRequest(context),
      onLeft: () {},
      onRight: () {},
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  void _handleSendRefillRequest(BuildContext context) {
    debugPrint('Refill request sent');

    //like a toast, if the refill button is selected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refill request sent')),
    );
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
      //same appBar for the other screens
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
          'Prescriptions',
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
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
          child: Column(
            children: [
              const PrescriptionCard(
                medicineName: 'Amoxicillin',
                dosage: '500 mg',
                instructions: '2 Capsules, 2 Time per Day',
                mealNote: 'Take Before Meal',
                timeLabel: '8:00 AM, 8:00 PM',
              ),
              const SizedBox(height: 18),
              const PrescriptionCard(
                medicineName: 'Ibuprofen',
                dosage: '400 mg',
                instructions: '1 Capsule, 1 Time per Day',
                mealNote: 'Take After Meal',
                timeLabel: '8:00 PM',
              ),
              const SizedBox(height: 25),
              const StatusBanner(
                icon: Icons.check_circle,
                label: 'Refill Needed?',
                description: 'Are you running low and need a refill?',
              ),
              const SizedBox(height: 12),
              ImageActionButton(
                imagePath: 'assets/images/send_refill_request.png',
                onPressed: () => _handleSendRefillRequest(context),
              ),
              const SizedBox(height: 20),
              const DeviceStatusImage(width: 351),
            ],
          ),
        ),
      ),
    );
  }
}

//class of the prescription card to avoid too much repitition
//all the dimensions taken from our design on figma
class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.instructions,
    required this.mealNote,
    required this.timeLabel,
  });

  final String medicineName;
  final String dosage;
  final String instructions;
  final String mealNote;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A16324F),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF79D0E1), Color(0xFF3F9DB8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/pill.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xFF1A2743),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      dosage,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xFF153B66),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instructions,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xFF697993),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mealNote,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xFF697993),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF57B4CC)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xFF73829A),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xFF153B66),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// A green pill-shaped informational banner with an icon, bold label, and optional text
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFC7EDB6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF89D368), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    color: Color(0xFF0B436E),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      color: Color(0xFF607494),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

// A fixed-size image button used for the "Send Refill Request" button
class ImageActionButton extends StatelessWidget {
  const ImageActionButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  final String imagePath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 341,
        height: 64,
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}
