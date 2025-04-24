// ignore_for_file: use_super_parameters, prefer_const_constructors, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback ontap;
  final String data;
  final Color textcolor, backgroundcolor;
  final double width,height;
  final IconData? icon;
  CustomButton({
    Key? key,
    required this.ontap,
    required this.data,
    required this.textcolor,
    required this.backgroundcolor,
    required this.width,
    required this.height,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: backgroundcolor,
        
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon),
            Text(
              textAlign: TextAlign.center,
              data,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textcolor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}