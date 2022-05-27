import 'package:flutter/material.dart';

class CusDivider extends StatelessWidget {
  const CusDivider({Key? key, required this.size, required this.widthPercent, required this.color}) : super(key: key);
  final Size size;
  final double widthPercent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.symmetric(vertical: size.height*.0),
      width: size.width * widthPercent,
      height: size.height*.0005,
      color: color,
    );
  }
}
