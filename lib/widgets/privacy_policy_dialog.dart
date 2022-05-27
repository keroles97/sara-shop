import 'package:app/providers/language_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({
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
          lang.get('privacy_policy'),
          style: TextStyle(
              color: theme.themeAccent,
              fontSize: size.width * 0.1,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: size.width * .8,
          height: size.height * .8,
          child: Center(
            child: Text(lang.get('privacy_policy_body')),
          ),
        ));
  }
}
