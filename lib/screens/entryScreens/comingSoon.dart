import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/theme.dart';

class Comingsoon extends StatefulWidget {
  const Comingsoon({super.key});

  @override
  State<Comingsoon> createState() => _ComingsoonState();
}

class _ComingsoonState extends State<Comingsoon> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: OtakuPlannerTheme.lightTheme,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 120.0,
              left: 30.0,
              right: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Coming Soon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  )
              ],
            ),
          ),
        ),  
      ),
    );
  }
}