import 'package:flutter/material.dart';

class HorizontalSpace extends StatelessWidget {
  const HorizontalSpace({Key? key, required this.size, required this.percentage})
      : super(key: key);
  final Size size;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * percentage,
    );
  }
}