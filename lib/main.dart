import 'package:app/providers/app_view_controller_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/providers/storage_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppViewControllerProvider>(
          create: (_) => AppViewControllerProvider()),
      ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider()),
      ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()),
      ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()),
      ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>(
          create: (_) => DatabaseProvider(),
          update: (ctx, auth, db) =>
          db!..getUserAuthData(auth.uId, auth.token, true)),
      ChangeNotifierProvider<StorageProvider>(
          create: (_) => StorageProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    theme.setStatusBarTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: lang.get('app_name'),
      themeMode: theme.getTheme(),
      theme: ThemeData(
        disabledColor: Colors.grey,
        hintColor: Colors.grey,
        primaryColor: theme.themeAccent,
        primarySwatch: theme.primarySwitch(),
        dialogBackgroundColor: theme.getBackground(),
        primaryIconTheme: IconThemeData(color: theme.themeAccent),
        unselectedWidgetColor: Colors.grey,
        canvasColor: theme.getBackground(),
        textTheme: theme.textTheme(),
      ),
      home: const MainPage(),
    );
  }
}
