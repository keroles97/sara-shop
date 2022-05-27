import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/screens/add_new_service.dart';
import 'package:app/screens/chat.dart';
import 'package:app/screens/chat_support.dart';
import 'package:app/screens/edit_service.dart';
import 'package:app/screens/profile.dart';
import 'package:app/screens/user_account_status.dart';
import 'package:app/screens/user_services.dart';
import 'package:app/widgets/cus_divider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../providers/app_view_controller_provider.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  List<Widget>? _screens;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedPageIndex = 0;

  void initializeScreens(AppViewControllerProvider avc) {
    _screens = [
      avc.isShowingEditScreen
          ? EditService(service: avc.editedService)
          : const UserServices(),
      const AddNewService(),
      avc.isShowingChatScreen
          ? Chat(chatData: avc.overviewedChatData)
          : const ChatSupport(),
      const Profile(),
      const UserAccountStatus(),
    ];
  }

  Future<void> _handleNavigationTap(int index) async {
    if (index == 5) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      return;
    }
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop();
  }

  bool _handleNavigationIcon() {
    var app = Provider.of<AppViewControllerProvider>(context, listen: true);
    if (_selectedPageIndex == 0 && app.isShowingEditScreen == true) {
      return false;
    } else if (_selectedPageIndex == 2 && app.isShowingChatScreen == true) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    initializeScreens(avc);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: _handleNavigationIcon()
          ? PreferredSize(
              preferredSize: Size.fromHeight(size.height * .05),
              child: Container(
                  height: size.height * .05,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: size.width * .04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                          onTap: () {
                            _scaffoldKey.currentState!.openDrawer();
                          },
                          child: Container(
                            height: size.height * .04,
                            width: size.width * .3,
                            alignment: lang.isEng()
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Icon(
                              theme.isIOS()
                                  ? CupertinoIcons.text_justify
                                  : Icons.menu,
                              color: theme.themeAccent,
                              size: size.height * .03,
                            ),
                          ))
                    ],
                  )),
            )
          : null,
      body: _screens![_selectedPageIndex],
      drawer: SizedBox(
        width: size.width * .7,
        child: Drawer(
          elevation: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: size.width * .7,
                  color: theme.themeAccent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VerticalSpace(size: size, percentage: 0.02),
                      Text(
                        db.user.name!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      VerticalSpace(size: size, percentage: 0.005),
                      Text(
                        db.user.email!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      VerticalSpace(size: size, percentage: 0.005),
                      _rateLayout(theme, db, size),
                      VerticalSpace(size: size, percentage: 0.03),
                    ],
                  ),
                ),
                CusDivider(size: size, widthPercent: 1, color: Colors.grey),
                drawerItem(
                  db,
                  lang,
                  theme,
                  size,
                  "my_services",
                  0,
                  theme.isIOS()
                      ? CupertinoIcons.creditcard
                      : Icons.account_balance_wallet_outlined,
                ),
                CusDivider(size: size, widthPercent: 1, color: Colors.grey),
                drawerItem(
                  db,
                  lang,
                  theme,
                  size,
                  "add_service",
                  1,
                  theme.isIOS()
                      ? CupertinoIcons.add_circled
                      : Icons.add_circle_outline,
                ),
                CusDivider(size: size, widthPercent: 1, color: Colors.grey),
                drawerItem(
                  db,
                  lang,
                  theme,
                  size,
                  "services_chat_support",
                  2,
                  theme.isIOS()
                      ? CupertinoIcons.chat_bubble_text_fill
                      : Icons.chat,
                ),
                CusDivider(size: size, widthPercent: 1, color: Colors.grey),
                drawerItem(
                  db,
                  lang,
                  theme,
                  size,
                  "my_profile",
                  3,
                  theme.isIOS()
                      ? CupertinoIcons.profile_circled
                      : Icons.account_circle_outlined,
                ),
                CusDivider(size: size, widthPercent: 1, color: Colors.grey),
                drawerItem(
                  db,
                  lang,
                  theme,
                  size,
                  "account_status",
                  4,
                  theme.isIOS()
                      ? CupertinoIcons.checkmark_seal
                      : Icons.check_circle_outline,
                ),
                CusDivider(size: size, widthPercent: 1, color: Colors.grey),
                drawerItem(
                  db,
                  lang,
                  theme,
                  size,
                  "logout",
                  5,
                  theme.isIOS()
                      ? CupertinoIcons.power
                      : Icons.power_settings_new,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawerItem(
      DatabaseProvider db,
      LanguageProvider lang,
      ThemeProvider theme,
      Size size,
      String textKey,
      int index,
      IconData icon) {
    return ListTile(
      horizontalTitleGap: 0,
      contentPadding:
          EdgeInsets.fromLTRB(size.width * .02, 0, size.width * .03, 0),
      selected: index == 5 ? false : _selectedPageIndex == index,
      selectedTileColor: theme.themeMode == "dark"
          ? const Color.fromRGBO(255, 255, 255, 0.1)
          : const Color.fromRGBO(219, 219, 219, 0.6),
      leading: Icon(
        icon,
        color: theme.swapBackground(),
      ),
      // trailing: index == 2 && db.unreadMessagesCount > 0
      //     ? Text(
      //         db.unreadMessagesCount.toString(),
      //         style: const TextStyle(color: Colors.green),
      //       )
      //     : null,
      title: Text(lang.get(textKey)),
      onTap: () => _handleNavigationTap(index),
    );
  }

  Widget _rateLayout(ThemeProvider theme, DatabaseProvider db, Size size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VerticalSpace(size: size, percentage: 0.005),
        RatingBarIndicator(
          rating: db.user.rate,
          itemBuilder: (context, index) => Icon(
            theme.isIOS() ? CupertinoIcons.star_fill : Icons.star,
            color: Colors.white,
          ),
          unratedColor: Colors.grey,
          itemCount: 5,
          itemSize: size.width * .04,
          direction: Axis.horizontal,
        ),
        SizedBox(
          width: size.width * .2,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                db.user.rate.toString(),
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * .013),
              ),
              Text(
                db.user.ratersCount.toString(),
                style: TextStyle(
                    color: Colors.white, fontSize: size.height * .013),
              )
            ],
          ),
        )
      ],
    );
  }
}
