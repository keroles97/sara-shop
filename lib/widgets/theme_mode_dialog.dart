import 'package:app/providers/language_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';

class ThemeModeDialog extends StatelessWidget {
  const ThemeModeDialog({
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
        content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Text(
              lang.get('light'),
              style: TextStyle(
                  fontSize: size.width * 0.06, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              theme.setThemeMode("light");
              Navigator.of(context).pop(context);
            },
          ),
          VerticalSpace(size: size, percentage: 0.01),
          TextButton(
            child: Text(
              lang.get('dark'),
              style: TextStyle(
                fontSize: size.width * 0.06, fontWeight: FontWeight.bold,),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              theme.setThemeMode("dark");
              Navigator.of(context).pop(context);
            },
          )
        ],
      ),
    ));
  }
}
