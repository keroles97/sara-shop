import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    required this.size,
    required this.lang,
    required this.theme,
  }) : super(key: key);
  final Size size;
  final LanguageProvider lang;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
          lang.get("delete_service_dialog_title"),
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
                  lang.get("delete"),
                  style: TextStyle(fontSize: size.width * 0.04),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              VerticalSpace(size: size, percentage: 0.001),
              TextButton(
                child: Text(
                  lang.get("cancel"),
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            ],
          ),
        ));
  }
}
