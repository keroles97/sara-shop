import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../widgets/vertical_space.dart';

class LanguageChooseScreen extends StatelessWidget {
  const LanguageChooseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.04,
          left: 1,
          right: 1,
          child: Center(
            child: ClipOval(
              child: Image.asset(
                "assets/app_icons/launcher_icon.png",
                width: size.height * 0.2,
                height: size.height * 0.2,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          right: 1,
          left: 1,
          bottom: size.height * 0.08,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text(
                  "ENGLISH",
                  style: TextStyle(
                      fontSize: size.width * 0.08, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  lang.setLanguage("english");
                },
              ),
              VerticalSpace(size: size, percentage: 0.01),
              TextButton(
                child: Text(
                  "عربي",
                  style: TextStyle(
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  lang.setLanguage("arabic");
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
