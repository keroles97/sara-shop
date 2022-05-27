import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class CusDialog extends StatelessWidget {
  const CusDialog({
    Key? key,
    required this.size,
    required this.lang,
    required this.theme,
    required this.action,
    required this.title,
    required this.posButton,
    required this.negButton,
  }) : super(key: key);
  final Size size;
  final LanguageProvider lang;
  final ThemeProvider theme;
  final Function action;
  final String title;
  final String posButton;
  final String negButton;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
          lang.get(title),
          style: TextStyle(
              color: theme.swapBackground(),
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                child: Text(
                  lang.get(posButton),
                  style: TextStyle(fontSize: size.width * 0.04),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  action;
                },
              ),
              VerticalSpace(size: size, percentage: 0.001),
              TextButton(
                child: Text(
                  lang.get(negButton),
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ));
  }
}
