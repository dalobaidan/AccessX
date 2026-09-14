import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import 'select_time.dart';
import '../data/app_data.dart';
import '../services/input_service.dart';
import 'dart:async';

class SelectDay extends StatefulWidget {
  final String doctorName;
  final String hospital;
  final String specialty;
  final String month;
  final String week; // used to look up the correct days list from app_data.dart

  const SelectDay({
    super.key,
    required this.doctorName,
    required this.hospital,
    required this.specialty,
    required this.month,
    required this.week,
  });

  @override
  State<SelectDay> createState() => _SelectDayState();
}

class _SelectDayState extends State<SelectDay> {
  int selectedIndex = 0;
  StreamSubscription<String>? _inputSub;
  bool _isActive = false;

  List<Map<String, String>> get days => daysByWeek[widget.week] ?? [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'select_day',
      isActive: () => _isActive,
      onUp: () {
        Navigator.pop(context); // back to week selection
      },
      onRight: () {
        _moveNextDay();
      },
      onLeft: () {
        _movePreviousDay();
      },
      onDown: () {
        _goToSelectTime(); // confirm selection
      },
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  void _moveNextDay() {
    if (days.isEmpty) return;

    setState(() {
      selectedIndex = (selectedIndex + 1) % days.length;
    });
  }

  void _movePreviousDay() {
    if (days.isEmpty) return;

    setState(() {
      selectedIndex = (selectedIndex - 1 + days.length) % days.length;
    });
  }

  void _goToSelectTime() {
    if (days.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectTime(
          doctorName: widget.doctorName,
          hospital: widget.hospital,
          specialty: widget.specialty,
          month: widget.month,
          week: widget.week,
          day: '${days[selectedIndex]['day']!} ${days[selectedIndex]['date']!}',
        ),
      ),
    );
  }

  String get formattedDoctorName {
    if (!widget.doctorName.contains(' ')) return widget.doctorName;

    return '${widget.doctorName.substring(0, widget.doctorName.lastIndexOf(' '))}\n'
        '${widget.doctorName.substring(widget.doctorName.lastIndexOf(' ') + 1)}';
  }

  void onDayTapped(int index) {
    if (selectedIndex == index) {
      _goToSelectTime(); // if already focused then activate
    } else {
      setState(() {
        selectedIndex = index; // focus first
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
            fontWeight: FontWeight.w500,
            color: Color(0xFF023859),
          ),
        ),
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                formattedDoctorName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF54ACBF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select Day',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF221F1F),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: List.generate(days.length, (index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => onDayTapped(index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: SizedBox(
                        width: 101,
                        height: 115,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              isSelected
                                  ? 'assets/images/day_selected.png'
                                  : 'assets/images/day_unselected.png',
                              width: 101,
                              height: 115,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Text(
                                    days[index]['day']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF023859),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -10),
                                    child: Text(
                                      days[index]['date']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 45,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF023859),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              //check the iot device connection
              Center(
                child: const DeviceStatusImage(width: 351),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
