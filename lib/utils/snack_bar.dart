import 'package:flutter/material.dart';

import '../providers/language_provider.dart';

void snackBar(BuildContext context, LanguageProvider lang, String textKey) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(lang.get(textKey)),
      action:
          SnackBarAction(label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );
}
