import 'package:app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({Key? key, required this.themeProvider})
      : super(key: key);
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SingleChildScrollView(
            child: BlockPicker(
      pickerColor: themeProvider.themeAccent,
      onColorChanged: (color) {
        themeProvider.setThemeColor(color);
        Navigator.of(context).pop(context);
      },
    )));
  }
}
