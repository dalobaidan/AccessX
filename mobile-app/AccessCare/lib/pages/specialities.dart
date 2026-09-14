import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';
import 'book_doctor.dart';

class SpecialtyCard extends StatelessWidget {
  final String title;
  final String defaultIconPath; // icon not selected
  final String selectedIconPath; // icon selected
  final bool isSelected;
  final VoidCallback onTap;

  const SpecialtyCard({
    super.key,
    required this.title,
    required this.defaultIconPath,
    required this.selectedIconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // selected card gets gradient background, unselected stays grey
          color: isSelected ? null : const Color(0xFFE6ECEF),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFA7EBF2),
                    Color(0xFF54ACBF),
                    Color(0xFF275059),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          // card shadowing
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // specialty icon, swaps between normal and selected version
              SizedBox(
                width: 80,
                height: 80,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Image.asset(
                    isSelected ? selectedIconPath : defaultIconPath,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  // white text on gradient, dark blue on grey
                  color: isSelected ? Colors.white : const Color(0xFF1F3B63),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// show 2 column grid of specialties
class Specialities extends StatefulWidget {
  const Specialities({super.key});

  @override
  State<Specialities> createState() => _SpecialitiesState();
}

class _SpecialitiesState extends State<Specialities> {
  int selectedIndex = 0; // which card is currently highlighted
  StreamSubscription<String>? _inputSub;
  bool _isActive = false;

  // list of specialties with their icons(normal and selected versions)
  final List<Map<String, String>> specialties = [
    {
      'title': 'Cardiology',
      'defaultIcon': 'assets/images/cardio.png',
      'selectedIcon': 'assets/images/cardio_selected.png',
    },
    {
      'title': 'Neurology',
      'defaultIcon': 'assets/images/neuro.png',
      'selectedIcon': 'assets/images/neuro_selected.png',
    },
    {
      'title': 'OB/GYN',
      'defaultIcon': 'assets/images/obgyn.png',
      'selectedIcon': 'assets/images/obgyn_selected.png',
    },
    {
      'title': 'Ophthalmology',
      'defaultIcon': 'assets/images/ophth.png',
      'selectedIcon': 'assets/images/ophth_selected.png',
    },
    {
      'title': 'Pediatrics',
      'defaultIcon': 'assets/images/pedia.png',
      'selectedIcon': 'assets/images/pedia_selected.png',
    },
    {
      'title': 'Orthopedics',
      'defaultIcon': 'assets/images/ortho.png',
      'selectedIcon': 'assets/images/ortho_selected.png',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'specialities',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(context),
      onLeft: _movePrevious,
      onRight: _moveNext,
      onDown: _goToSelectedSpecialty,
    );
  }

  @override
  void dispose() {
    // cancel listener when leaving
    _inputSub?.cancel();
    super.dispose();
  }

  // wrap around at the end
  void _moveNext() {
    setState(() {
      selectedIndex = (selectedIndex + 1) % specialties.length;
    });
  }

  // wraps around to the end if at the start
  void _movePrevious() {
    setState(() {
      selectedIndex =
          (selectedIndex - 1 + specialties.length) % specialties.length;
    });
  }

  // get the selected specialty and go to the doctor booking screen
  void _goToSelectedSpecialty() {
    final specialty = specialties[selectedIndex]['title']!;
    _goToBookDoctor(specialty);
  }

  // show the BookDoctor screen with the chosen specialty
  void _goToBookDoctor(String specialty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookDoctor(specialty: specialty)),
    );
  }

  // home button in the app bar
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
          'Book Appointment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        // home icon on the app bar
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Specialties',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F3B63),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: specialties.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final item = specialties[index];

                        return SpecialtyCard(
                          title: item['title']!,
                          defaultIconPath: item['defaultIcon']!,
                          selectedIconPath: item['selectedIcon']!,
                          isSelected: selectedIndex == index,
                          onTap: () {
                            if (selectedIndex == index) {
                              _goToBookDoctor(item['title']!);
                            } else {
                              setState(() {
                                selectedIndex = index;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // device connection status
              Positioned(
                left: 0,
                right: 0,
                bottom: -5,
                child: Center(
                  child: const DeviceStatusImage(width: 351),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
