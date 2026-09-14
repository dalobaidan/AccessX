import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_project/widgets/device_status.dart';
import '../services/input_service.dart';
import 'dart:async';

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

//this page contains images regarding the gestures with description for the iot device (headband)
class _TutorialState extends State<Tutorial> {
  StreamSubscription<String>? _inputSub;

  @override
  void initState() {
    super.initState();

    _inputSub = inputService.listenToPage(
      pageId: 'tutorial',
      isActive: () => ModalRoute.of(context)?.isCurrent ?? false,
      onUp: () {
        Navigator.pop(context);
      },
      onDown: () {
        Navigator.pushNamed(context, '/account');
      },
    );
  }

  @override
  void dispose() {
    _inputSub?.cancel();
    super.dispose();
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
          'Tutorial',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Row(
                      children: [
                        //the images right left down up with descriptions under
                        Expanded(
                          child: TutorialBox(
                            imagePath: 'assets/images/tutorial_right.png',
                            text: 'Tilt right to\ngo next',
                          ),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: TutorialBox(
                            imagePath: 'assets/images/tutorial_left.png',
                            text: 'Tilt left to\ngo previous',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Expanded(
                          child: TutorialBox(
                            imagePath: 'assets/images/tutorial_down.png',
                            text: 'Nod Down\nto select',
                          ),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: TutorialBox(
                            imagePath: 'assets/images/tutorial_up.png',
                            text: 'Move Up for previous page',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 45),
                    GestureDetector(
                      //without opaque, sometimes only the visible child area may react to taps
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pushNamed(context, '/account');
                      },
                      child: Image.asset(
                        'assets/images/continue_focused.png',
                        width: 323,
                        height: 64,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: const DeviceStatusImage(width: 351),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//to make it consistent instead of four times
class TutorialBox extends StatelessWidget {
  final String imagePath;
  final String text;

  const TutorialBox({super.key, required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7890),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
