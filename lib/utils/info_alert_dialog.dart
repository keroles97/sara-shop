import 'package:flutter/material.dart';

import '../providers/language_provider.dart';

void showInfoAlertDialog(
    BuildContext context, LanguageProvider lang, String message, bool isError) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text(
                isError ? lang.get('error_occurred') : lang.get('succeed')),
            content: Text(lang.get(message)),
            actions: [
              TextButton(
                child: Text(lang.get('ok')),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ));
}
