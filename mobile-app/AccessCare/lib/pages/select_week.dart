import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import 'select_day.dart';
import '../data/app_data.dart';
import '../services/input_service.dart';
import 'dart:async';

class SelectWeek extends StatefulWidget {
  final String doctorName;
  final String hospital;
  final String specialty;
  final String month;

  const SelectWeek({
    super.key,
    required this.doctorName,
    required this.hospital,
    required this.specialty,
    required this.month, // used to look up the correct week list from app_data.dart
  });

  @override
  State<SelectWeek> createState() => _SelectWeekState();
}

class _SelectWeekState extends State<SelectWeek> {
  int selectedIndex = 0;
  StreamSubscription<String>? _inputSub;
  bool _isActive = false;

  // we read from the static app_data map keyed by month name
  List<String> get weeks => weeksByMonth[widget.month] ?? [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isActive = ModalRoute.of(context)?.isCurrent ?? false;
  }

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'select_week',
      isActive: () => _isActive,
      onUp: () {
        Navigator.pop(context); // back to month selection
      },
      onRight: () {
        _moveNextWeek();
      },
      onLeft: () {
        _movePreviousWeek();
      },
      onDown: () {
        _goToSelectDay(); // confirm selection
      },
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
  }

  void _moveNextWeek() {
    if (weeks.isEmpty) return;

    setState(() {
      selectedIndex = (selectedIndex + 1) % weeks.length;
    });
  }

  void _movePreviousWeek() {
    if (weeks.isEmpty) return;

    setState(() {
      selectedIndex = (selectedIndex - 1 + weeks.length) % weeks.length;
    });
  }

  // add the selected week string to the constructor
  void _goToSelectDay() {
    if (weeks.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDay(
          doctorName: widget.doctorName,
          hospital: widget.hospital,
          specialty: widget.specialty,
          month: widget.month,
          week: weeks[selectedIndex],
        ),
      ),
    );
  }

  String get formattedDoctorName {
    if (!widget.doctorName.contains(' ')) return widget.doctorName;

    return '${widget.doctorName.substring(0, widget.doctorName.lastIndexOf(' '))}\n'
        '${widget.doctorName.substring(widget.doctorName.lastIndexOf(' ') + 1)}';
  }

  void onWeekTapped(int index) {
    if (selectedIndex == index) {
      _goToSelectDay();
    } else {
      setState(() {
        selectedIndex = index;
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
              'assets/images/progress_indicator_2.png',
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
                'Select Week',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF221F1F),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: List.generate(weeks.length, (index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => onWeekTapped(index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SizedBox(
                        width: 304,
                        height: 109,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              isSelected
                                  ? 'assets/images/week_selected.png'
                                  : 'assets/images/week_unselected.png',
                              width: 304,
                              height: 109,
                              fit: BoxFit.fill,
                            ),

                            //all positions/dimensions are taken from our design on Figma
                            Positioned(
                              top: 23,
                              left: 0,
                              right: 0,
                              child: Text(
                                weeks[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF023859),
                                ),
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
              //to check the iot device status
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
