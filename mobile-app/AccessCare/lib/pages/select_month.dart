import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import 'select_week.dart';
import '../services/input_service.dart';
import 'dart:async';

class SelectMonth extends StatefulWidget {
  final String doctorName;
  final String hospital;
  final String specialty;

  const SelectMonth({
    super.key,
    required this.doctorName,
    required this.hospital,
    required this.specialty,
  });

  @override
  State<SelectMonth> createState() => _SelectMonthState();
}

class _SelectMonthState extends State<SelectMonth> {
  // available months for now
  final List<String> months = ['April', 'May', 'June'];
  int selectedIndex = 0;
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

    // same input as the previous screen
    _inputSub = inputService.listenToPage(
      pageId: 'select_month',
      isActive: () => _isActive,
      onUp: () {
        Navigator.pop(context);
      },
      onRight: () {
        _moveNextMonth();
      },
      onLeft: () {
        _movePreviousMonth();
      },
      onDown: () {
        _goToSelectWeek();
      },
    );
  }

  @override
  void dispose() {
    // cancel listener when leaving
    _inputSub?.cancel();
    super.dispose();
  }

  // move to the next month, wraps around
  void _moveNextMonth() {
    setState(() {
      selectedIndex = (selectedIndex + 1) % months.length;
    });
  }

  // move to the previous month, wraps around
  void _movePreviousMonth() {
    setState(() {
      selectedIndex = (selectedIndex - 1 + months.length) % months.length;
    });
  }

  // go to the week selection screen, and pass data forward
  void _goToSelectWeek() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectWeek(
          doctorName: widget.doctorName,
          hospital: widget.hospital,
          specialty: widget.specialty,
          month: months[selectedIndex],
        ),
      ),
    );
  }

  // split doctor's name on separate lines
  // if only one word, just return it as is
  String get formattedDoctorName {
    if (!widget.doctorName.contains(' ')) return widget.doctorName;

    return '${widget.doctorName.substring(0, widget.doctorName.lastIndexOf(' '))}\n'
        '${widget.doctorName.substring(widget.doctorName.lastIndexOf(' ') + 1)}';
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
        // progress bar at the top to show booking progess

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 18),
            child: Column(
              // doctor name displayed at the top
              children: [
                Text(
                  formattedDoctorName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF54ACBF),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Month',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF221F1F),
                  ),
                ),
                const SizedBox(height: 26),

                // make a card for each month
                Column(
                  children: List.generate(months.length, (index) {
                    final bool isSelected = selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GestureDetector(
                        onTap: () {
                          // first tap selects the month, second tap confirms it
                          if (selectedIndex == index) {
                            _goToSelectWeek();
                          } else {
                            setState(() {
                              selectedIndex = index;
                            });
                          }
                        },
                        child: Center(
                          child: Container(
                            width: 223,
                            height: 84,
                            decoration: BoxDecoration(
                              // selected month has gradient background, unselected gets grey
                              color:
                                  isSelected ? null : const Color(0xFFE6ECEF),
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
                              borderRadius: BorderRadius.circular(24),
                              // shadowing around the card
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.12),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                months[index],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                  // white text on gradient, dark blue on the grey
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF023859),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 140),

                // device connection status
                Center(
                  child: const DeviceStatusImage(width: 351),
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
