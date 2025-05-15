import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Icon icon;
  final int currentStep;
  final Color color;

  const SummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.currentStep,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      width: MediaQuery.of(context).size.width / 2 - 50,
      decoration: BoxDecoration(
        color: Color.fromRGBO(252, 242, 232, 1),
        border: Border.all(color: Colors.black, width: 0.4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                icon,
              ],
            ),
            SizedBox(height: 15),
            Text("3", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text(subtitle, style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            StepProgressIndicator(
              totalSteps: 100,
              currentStep: currentStep,
              size: 8,
              padding: 0,
              roundedEdges: Radius.circular(10),
              selectedGradientColor: LinearGradient(colors: [color, color]),
              unselectedGradientColor: LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300]),
            ),
          ],
        ),
      ),
    );
  }
}
