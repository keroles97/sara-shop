import 'package:app/widgets/settings_button.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_view_controller_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    return Stack(children: [
      Positioned(
        top: size.height * 0.04,
        left: 1,
        right: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "assets/app_icons/launcher_icon.png",
                width: size.height * 0.17,
                height: size.height * 0.17,
                fit: BoxFit.cover,
              ),
            ),
            VerticalSpace(size: size, percentage: 0.01),
            Text(
              lang.get('app_name'),
              style: TextStyle(
                  fontSize: size.width * 0.08, fontWeight: FontWeight.bold),
            ),
            VerticalSpace(size: size, percentage: 0.004),
            Text(
              "v1.0.0",
              style: TextStyle(
                  color: theme.swapBackground(), fontSize: size.width * 0.05),
            ),
          ],
        ),
      ),
      Positioned(
        left: 1,
        right: 1,
        bottom: size.height * 0.04,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SettingsButton(
                size: size,
                ctx: context,
                lang: lang,
                theme: theme,
                textKey: "language"),
            SettingsButton(
                size: size,
                ctx: context,
                lang: lang,
                theme: theme,
                textKey: "theme_color"),
            SettingsButton(
                size: size,
                ctx: context,
                lang: lang,
                theme: theme,
                textKey: "theme_mode"),
            SettingsButton(
                size: size,
                ctx: context,
                lang: lang,
                theme: theme,
                textKey: "contact_us"),
            // SettingsButton(
            //     size: size,
            //     ctx: context,
            //     lang: lang,
            //     theme: theme,
            //     textKey: "privacy_policy"),
          ],
        ),
      )
    ]);
  }
}
