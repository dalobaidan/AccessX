import 'package:flutter/material.dart';
import 'package:mobile_project/pages/auth.dart';
import 'package:mobile_project/pages/dashboard.dart';
import 'package:mobile_project/pages/login_first.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        //if snapshot.hasData is true firebase confirmed a logged-in user
        if (snapshot.hasData) {
          return const Dashboard();
        } else {
          //to check if someone is actually logged in or firebase is still loading
          return const LoginFirst();
        }
      },
    );
  }
}
