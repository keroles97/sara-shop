import 'package:flutter/material.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class FormSubmitButton extends StatelessWidget {
  const FormSubmitButton(
      {Key? key,
      required this.size,
      required this.lang,
      required this.theme,
      required this.textKey,
      required this.fun})
      : super(key: key);
  final Size size;
  final LanguageProvider lang;
  final ThemeProvider theme;
  final String textKey;
  final void Function() fun;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: size.width * .05, vertical: 0),
      child: ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(vertical: size.height * .01)),
            shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
          onPressed: fun,
          child: Text(
            lang.get(textKey),
            style: TextStyle(fontSize: size.height * .025, color: Colors.white),
          )),
    );
  }
}
