import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';

import '../services/input_service.dart';
import 'confirmation.dart';

class SelectTime extends StatefulWidget {
  final String doctorName;
  final String hospital;
  final String specialty;
  final String month;
  final String week;
  final String day;

  const SelectTime({
    super.key,
    required this.doctorName,
    required this.hospital,
    required this.specialty,
    required this.month,
    required this.week,
    required this.day,
  });

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  int selectedIndex = 0;
  bool _hasNavigated = false;
  bool _isActive = false;

  final ScrollController _scrollController = ScrollController();

  StreamSubscription<String>? _inputSub;

  // example times we provided from 9:00 to 2:00.
  final List<String> times = [
    '9:00',
    '9:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '1:00',
    '1:30',
    '2:00',
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
      pageId: 'select_time',
      isActive: () => _isActive,
      onUp: () => Navigator.pop(context), // back to day selection
      onRight: _moveNextTime,
      onLeft: _movePreviousTime,
      onDown: _goToConfirmation,
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _moveNextTime() {
    setState(() {
      if (selectedIndex < times.length - 1) {
        selectedIndex++;
      }
    });

    _scrollToSelected();
  }

  void _movePreviousTime() {
    setState(() {
      if (selectedIndex > 0) {
        selectedIndex--;
      }
    });

    _scrollToSelected();
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final offset = (selectedIndex * 65.0) - 100;

      _scrollController.animateTo(
        // clamp() ensures we never try to scroll past 0 or past maxScrollExtent,
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goToConfirmation() {
    if (_hasNavigated) return;

    _hasNavigated = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Confirmation(
          doctorName: widget.doctorName,
          hospital: widget.hospital,
          specialty: widget.specialty,
          month: widget.month,
          week: widget.week,
          day: widget.day,
          time: times[selectedIndex],
        ),
      ),
    ).then((_) {
      _hasNavigated = false;
    });
  }

  // Single tap: focus on first tap, navigate on second
  void onTimeTapped(int index) {
    if (selectedIndex == index) {
      _goToConfirmation();
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  // double tap: skip the focus step, go straight to confirmation
  void onTimeDoubleTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    _goToConfirmation();
  }

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
            fontWeight: FontWeight.w500,
            color: Color(0xFF023859),
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
      body: Column(
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
            'Select Time',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF221F1F),
            ),
          ),
          const SizedBox(height: 16),
          // Expanded gives the ListView all remaining vertical space between the heading and the device status image
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: times.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => onTimeTapped(index),
                    onDoubleTap: () => onTimeDoubleTapped(index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Center(
                        child: SizedBox(
                          width: 100,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                isSelected
                                    ? 'assets/images/time_selected.png'
                                    : 'assets/images/time_unselected.png',
                                width: 100,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                              Text(
                                times[index],
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          //check the iot device status
          Center(
            child: const DeviceStatusImage(width: 351),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
