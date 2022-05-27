import 'package:flutter/material.dart';

class VerticalSpace extends StatelessWidget {
  const VerticalSpace({Key? key, required this.size, required this.percentage})
      : super(key: key);
  final Size size;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * percentage,
    );
  }
}