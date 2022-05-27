import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_button.dart';
import '../widgets/vertical_space.dart';

class UserAccountStatus extends StatelessWidget {
  const UserAccountStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * .1),
            child: Text(
              lang.get(db.user.active
                  ? "account_status_active"
                  : "account_status_inactive"),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: size.width * .05),
            ),
          ),
          VerticalSpace(size: size, percentage: .04),
          db.user.active
              ? const Icon(
                  Icons.thumb_up,
                  color: Colors.green,
                )
              : const Icon(
                  Icons.thumb_down,
                  color: Colors.red,
                ),
          VerticalSpace(size: size, percentage: .04),
          SettingsButton(
              size: size,
              ctx: context,
              lang: lang,
              theme: theme,
              textKey: "contact_us")
        ],
      ),
    );
  }
}
