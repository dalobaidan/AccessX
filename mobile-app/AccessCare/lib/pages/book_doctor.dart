import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import 'select_month.dart';
import '../data/app_data.dart';
import '../services/input_service.dart';
import 'dart:async';

//doctor card
class DoctorCard extends StatelessWidget {
  final String initials;
  final String name;
  final String hospital;
  final String starsImagePath;
  final bool isSelected; // whether this doctor is currently selected
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.initials,
    required this.name,
    required this.hospital,
    required this.starsImagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor =
        isSelected ? const Color(0xFFE9EEF2) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // the circle on the left to show the doctor's initials
            // if a dr is selected, make background blue, if not background is grey
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFA9DCEB), Color(0xFF74AFC2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFC8D2DC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    // white text on blue background, dark blue on the grey
                    color: isSelected ? Colors.white : const Color(0xFF1F3B63),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // name, hospital location, and star rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF141B34),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        //pin icon next to hospital name
                        Icons.location_on_outlined,
                        size: 18,
                        color: Color(0xFF6EA9BC),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Color(0xFF6EA9BC),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // star rating
                  Image.asset(
                    starsImagePath,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// List of doctors for whatever specialty was passed in
class BookDoctor extends StatefulWidget {
  final String specialty;

  const BookDoctor({
    super.key,
    required this.specialty,
  });

  @override
  State<BookDoctor> createState() => _BookDoctorState();
}

class _BookDoctorState extends State<BookDoctor> {
  int selectedDoctorIndex =
      0; // keep track of which doctor is currently highlighted
  StreamSubscription<String>? _inputSub; // listen for remote input
  bool _isActive = false;

  // get the right list of doctors based on the specialty received
  List<Map<String, String>> get doctors =>
      doctorsBySpecialty[widget.specialty] ?? [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'book_doctor',
      isActive: () => _isActive,
      onUp: () {
        Navigator.pop(context); // go back to previous page
      },
      onRight: () {
        _moveNextDoctor(); // highlight the next doctor in the list
      },
      onLeft: () {
        _movePreviousDoctor(); // highlight the previous doctor
      },
      onDown: () {
        _goToSelectMonth(); // confirm the selected doctor and go to next page
      },
    );
  }

  @override
  void dispose() {
    // cancel listener when leaving
    _inputSub?.cancel();
    super.dispose();
  }

  // so selection can wrap around to the first doctor if we're at the end
  void _moveNextDoctor() {
    if (doctors.isEmpty) return;

    setState(() {
      selectedDoctorIndex = (selectedDoctorIndex + 1) % doctors.length;
    });
  }

  // same here but wraps around to the last doctor if we're at the start
  void _movePreviousDoctor() {
    if (doctors.isEmpty) return;

    setState(() {
      selectedDoctorIndex =
          (selectedDoctorIndex - 1 + doctors.length) % doctors.length;
    });
  }

  // go to the month selection screen
  void _goToSelectMonth() {
    if (doctors.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMonth(
          doctorName: doctors[selectedDoctorIndex]['name']!,
          hospital: doctors[selectedDoctorIndex]['hospital']!,
          specialty: widget.specialty,
        ),
      ),
    );
  }

  // first tap means select the doctor, second tap means go to next screen
  void _handleDoctorTap(int index) {
    if (selectedDoctorIndex == index) {
      _goToSelectMonth(); // confirming selection
    } else {
      setState(() {
        selectedDoctorIndex = index; // just highlight the dr
      });
    }
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
        automaticallyImplyLeading: false, // back button
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/images/back.svg',
            width: 40,
            height: 40,
          ),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // specialty title at the top
                Text(
                  widget.specialty,
                  style: const TextStyle(
                    fontSize: 40,
                    height: 1,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F3B63),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Doctor',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F3B63),
                  ),
                ),
                const SizedBox(height: 18),
                // make one dr card for each dr in the list
                Column(
                  children: List.generate(doctors.length, (index) {
                    final doctor = doctors[index];

                    return DoctorCard(
                      initials: doctor['initials']!,
                      name: doctor['name']!,
                      hospital: doctor['hospital']!,
                      starsImagePath: 'assets/images/stars.png',
                      isSelected: selectedDoctorIndex == index,
                      onTap: () => _handleDoctorTap(index),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                // device connection status
                Center(
                  child: DeviceStatusImage(width: 351),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
