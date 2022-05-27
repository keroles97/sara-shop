import 'package:app/providers/database_provider.dart';
import 'package:app/screens/favorite_services_tab.dart';
import 'package:app/screens/loading.dart';
import 'package:app/screens/services_tab.dart';
import 'package:app/screens/settings_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../providers/app_view_controller_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import 'account_tab.dart';

class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  bool _userDataLoaded = false;
  int _selectedPageIndex = 0;

  final List<Widget> _screens = [
    const ServicesTab(),
    const FavoriteServicesTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  void _handleNavigationTap(int index) {
    final avc = Provider.of<AppViewControllerProvider>(context, listen: false);
    avc.setShowingServiceOverviewScreen(false);
    avc.setShowingSellerOverviewScreen(false);
    avc.setShowingChatScreen(false);
    avc.setShowingEditScreen(false);
    setState(() {
      _selectedPageIndex = index;
    });
  }

  Future<void> _getUserData() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    try {
      await db.getUserData();
      setState(() {
        _userDataLoaded = true;
      });
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('tabs_getUserData: ' + error.toString());
      }
      showInfoAlertDialog(
          context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('tabs_getUserData: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    }
  }

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    return _userDataLoaded
        ? DefaultTabController(
            length: 3,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: _screens[_selectedPageIndex],
              bottomNavigationBar: BottomNavigationBar(
                elevation: 16,
                backgroundColor: theme.getBackground(),
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedPageIndex,
                onTap: _handleNavigationTap,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(
                          theme.isIOS() ? CupertinoIcons.home : Icons.home),
                      label: lang.get("tab_home")),
                  BottomNavigationBarItem(
                      icon: Icon(theme.isIOS()
                          ? CupertinoIcons.heart_fill
                          : Icons.favorite),
                      label: lang.get("tab_favorites")),
                  BottomNavigationBarItem(
                      icon: Icon(theme.isIOS()
                          ? CupertinoIcons.person_fill
                          : Icons.person),
                      label: lang.get("tab_account")),
                  BottomNavigationBarItem(
                      icon: Icon(theme.isIOS()
                          ? CupertinoIcons.settings
                          : Icons.settings),
                      label: lang.get("tab_settings")),
                ],
              ),
            ),
          )
        : const LoadingScreen();
  }
}
