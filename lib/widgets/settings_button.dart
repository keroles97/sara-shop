import 'package:app/providers/language_provider.dart';
import 'package:app/widgets/contact_us_dialog.dart';
import 'package:app/widgets/language_dialog.dart';
import 'package:app/widgets/privacy_policy_dialog.dart';
import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';
import 'color_picker_dialog.dart';
import 'theme_mode_dialog.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton(
      {Key? key,
      required this.size,
      required this.ctx,
      required this.lang,
      required this.theme,
      required this.textKey})
      : super(key: key);
  final Size size;
  final BuildContext ctx;
  final LanguageProvider lang;
  final ThemeProvider theme;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.themeAccent, width: 1)),
      width: double.infinity,
      height: size.height * 0.065,
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.011,
        horizontal: size.width * 0.08,
      ),
      child: TextButton(
        child: Text(
          lang.get(textKey),
          style: TextStyle(
              color: theme.themeAccent, fontSize: size.width * 0.06),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          showDialog(
              context: ctx,
              builder: (BuildContext ctx) {
                switch (textKey) {
                  case "language":
                    return LanguageDialog(size: size,lang: lang);
                    case "theme_color":
                    return ColorPickerDialog(themeProvider: theme);
                  case "theme_mode":
                    return ThemeModeDialog(
                      size: size,
                      lang: lang,
                      theme: theme,
                    );
                  case "privacy_policy":
                    return PrivacyPolicyDialog(
                      size: size,
                      lang: lang,
                      theme: theme,
                    );
                    case "contact_us":
                    return ContactUsDialog(
                      size: size,
                      lang: lang,
                      theme: theme,
                    );
                  default:
                    return Container();
                }
              });
        },
      ),
    );
  }
}
