import 'package:app/constants.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/theme_provider.dart';

class ContactUsDialog extends StatelessWidget {
  const ContactUsDialog({
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
          lang.get("contact_us_message"),
          style: TextStyle(
              fontSize: size.width * 0.06,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: size.height*.2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text(
                  constants["email"]!,
                  style: TextStyle(fontSize: size.height * 0.023),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(context);
                  launchUrl(Uri.parse("mailto:" + constants["email"]!));
                },
              ),
              VerticalSpace(size: size, percentage: 0.004),
              TextButton(
                child: Text(
                  constants["phone"]!,
                  style: TextStyle(
                    fontSize: size.height * 0.023,
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.of(context).pop(context);
                  launchUrl(Uri.parse(
                      "whatsapp://send?phone=" + constants["phone"]!));
                },
              )
            ],
          ),
        ));
  }
}
