import 'package:app/providers/app_view_controller_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/language_choose.dart';
import 'package:app/screens/loading.dart';
import 'package:app/screens/login_register.dart';
import 'package:app/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<bool> _handleBackNavigation(BuildContext context, Size size,
      LanguageProvider lang, ThemeProvider theme) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                lang.get('exit'),
                textAlign: lang.isEng() ? TextAlign.left : TextAlign.right,
                style: TextStyle(
                    color: theme.swapBackground(),
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(lang.get('cancel'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.themeAccent)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemNavigator.pop();
                  },
                  child: Text(
                    lang.get('exit'),
                  ),
                ),
              ],
            ));
    return false;
  }

  @override
  void initState() {
    Provider.of<LanguageProvider>(context, listen: false).loadLanguagePrefs();
    Provider.of<ThemeProvider>(context, listen: false).loadThemePrefs();
    Provider.of<AuthProvider>(context, listen: false).tryAutoSignIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    return WillPopScope(
      onWillPop: () => _handleBackNavigation(context, size, lang, theme),
      child: SafeArea(
          child: Directionality(
              textDirection: lang.getDirection(),
              child: Scaffold(
                body: lang.loaded && theme.loaded && auth.loaded
                    ? lang.isLanguageSet()
                        ? auth.isAuth
                            ? const Tabs()
                            : const LoginRegisterScreen()
                        : const LanguageChooseScreen()
                    : const LoadingScreen(),
              ))),
    );
  }
}
