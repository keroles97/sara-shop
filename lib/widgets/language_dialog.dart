import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';

import '../providers/language_provider.dart';


class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    Key? key,
    required this.size,
    required this.lang,
  }) : super(key: key);
  final Size size;
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Text(
              "ENGLISH",
              style: TextStyle(
                  fontSize: size.height * 0.03, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              lang.setLanguage("english");
              Navigator.of(context).pop(context);
            },
          ),
          VerticalSpace(size: size, percentage: 0.001),
          TextButton(
            child: Text(
              "عربي",
              style: TextStyle(
                fontSize: size.height * 0.03,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              lang.setLanguage("arabic");
              Navigator.of(context).pop(context);
            },
          )
        ],
      ),
    ));
  }
}
