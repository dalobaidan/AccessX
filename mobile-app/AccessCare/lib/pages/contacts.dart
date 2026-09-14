import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/input_service.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  int selectedIndex =
      0; // 0 = current doctor, 1 = previous doctor, 2 = emergency
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
      pageId: 'contacts',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(context), //back to previous page (dashboard)
      onLeft: () {
        setState(() {
          // Wrap backward through 3 items
          selectedIndex = (selectedIndex - 1 + 3) % 3;
        });
      },
      onRight: () {
        setState(() {
          //wrap forward
          selectedIndex = (selectedIndex + 1) % 3;
        });
      },
      onDown: _activateSelected,
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  //the method to call a number
  Future<void> _callNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      debugPrint('Could not launch phone call');
    }
  }

  //we passed sara's number as a trial
  //all three buttons call the same number
  void _activateSelected() {
    _callNumber('0534342060');
  }

  void _handleRequestAid(BuildContext context, String doctorName) {
    _callNumber('0534342060');
  }

  void _handleEmergency(BuildContext context) {
    _callNumber('0534342060');
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
      //same appBar as the rest of the pages with back and home buttons
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
          'Contacts',
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
        //to avoid overflow
        child: SingleChildScrollView(
          //we took the numbers from our Figma desing
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
          child: Column(
            children: [
              //we added these data for showing
              DoctorCard(
                isSelected: selectedIndex == 0,
                tagLabel: 'Current Doctor',
                tagColor: const Color(0xFFD8F3C6),
                tagTextColor: const Color(0xFF86D36B),
                initials: 'SM',
                doctorName: 'Dr. Sarah Mohammed',
                specialty: 'Cardiologist',
                location: 'Dr. Alhabib - Takhasussi',
                onPressed: () =>
                    _handleRequestAid(context, 'Dr. Sarah Mohammed'),
              ),
              const SizedBox(height: 20),
              DoctorCard(
                isSelected: selectedIndex == 1,
                tagLabel: 'Previous Doctor',
                tagColor: const Color(0xFFFFD2DC),
                tagTextColor: const Color(0xFFFF4F67),
                initials: 'SA',
                doctorName: 'Dr. Saleh Ahmad',
                specialty: 'Neurology',
                location: 'Dr. Alhabib - Takhasussi',
                onPressed: () => _handleRequestAid(context, 'Dr. Saleh Ahmad'),
              ),
              const SizedBox(height: 28),
              EmergencyImageButton(
                isSelected: selectedIndex == 2,
                imagePath: 'assets/images/emergency_button.png',
                onPressed: () => _handleEmergency(context),
              ),
              const SizedBox(height: 20),
              //to check iot device status
              const DeviceStatusImage(width: 351),
            ],
          ),
        ),
      ),
    );
  }
}

//a single class to avoid repeating the same design multiple times
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.isSelected,
    required this.tagLabel,
    required this.tagColor,
    required this.tagTextColor,
    required this.initials,
    required this.doctorName,
    required this.specialty,
    required this.location,
    required this.onPressed,
  });

  final bool isSelected;
  final String tagLabel;
  final Color tagColor;
  final Color tagTextColor;
  final String initials;
  final String doctorName;
  final String specialty;
  final String location;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    //its like a container but to make the buttons shade change
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(20),
      //Because it is inside an animatedContainer, the color fades smoothly instead of changing suddenly.
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE9EEF2) : Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tagLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: tagTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF79D0E1), Color(0xFF3F9DB8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF1A2743),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF18385A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        //we used icons from flutter
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF5BAEC4),
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF5BAEC4),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          RequestAidImageButton(
            imagePath: 'assets/images/request_aid.png',
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

//the button for the request aid
class RequestAidImageButton extends StatelessWidget {
  const RequestAidImageButton({
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
        width: double.infinity,
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}

//the button for emergency
class EmergencyImageButton extends StatelessWidget {
  const EmergencyImageButton({
    super.key,
    required this.isSelected,
    required this.imagePath,
    required this.onPressed,
  });

  final bool isSelected;
  final String imagePath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isSelected ? const Color(0xFFE9EEF2) : Colors.transparent,
      ),
      padding: EdgeInsets.all(isSelected ? 6 : 0),
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
