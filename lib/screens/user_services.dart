import 'package:app/models/service_model.dart';
import 'package:app/providers/app_view_controller_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/storage_provider.dart';
import 'package:app/screens/loading.dart';
import 'package:app/utils/snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/vertical_space.dart';

class UserServices extends StatefulWidget {
  const UserServices({Key? key}) : super(key: key);

  @override
  State<UserServices> createState() => _UserServicesState();
}

class _UserServicesState extends State<UserServices> {
  bool _servicesDataLoaded = false;
  final List<ServiceModel> _services = [];
  bool _loading = false;

  void _serviceStatusSubmit(
    AuthProvider auth,
    DatabaseProvider db,
    LanguageProvider lang,
    String serviceId,
    int serviceIndex,
    bool value,
  ) async {
    setState(() {
      _loading = true;
    });
    try {
      await db.put('services/$serviceId/active', value);
      _services[serviceIndex].active = value;
      snackBar(context, lang, 'update_success');
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('service_status_submit: ' + error.toString());
      }
      showInfoAlertDialog(
          context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('service_status_submit: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _serviceDeleteSubmit(
    AuthProvider auth,
    DatabaseProvider db,
    StorageProvider storage,
    LanguageProvider lang,
    String serviceId,
    int serviceIndex,
  ) async {
    setState(() {
      _loading = true;
    });
    try {
      for (int i = 0; i < _services[serviceIndex].images!.length; i++) {
        await storage
            .delete('users/${db.user.uId}/servicesImages/$serviceId/image$i');
      }
      await storage.delete('users/${db.user.uId}/servicesImages/$serviceId/');

      await db.delete('services/$serviceId');
      _services.removeAt(serviceIndex);
      snackBar(context, lang, 'update_success');
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('service_delete_submit: ' + error.toString());
      }
      showInfoAlertDialog(
          context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('service_delete_submit: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void prepareServicesToView(dynamic data) {
    if (data != null) {
      for (var e in data.values) {
        _services.add(ServiceModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }

    setState(() {
      _servicesDataLoaded = true;
    });
  }

  Future<void> _getData() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    try {
      db.get('services', '&orderBy="sellerUid"&equalTo=":uid"').then((value) {
        prepareServicesToView(value);
      });
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('user_services_getData: ' + error.toString());
      }
      showInfoAlertDialog(
          context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('user_services_getData: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    }
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final auth = Provider.of<AuthProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    final storage = Provider.of<StorageProvider>(context, listen: true);
    return _servicesDataLoaded
        ? _services.isNotEmpty
            ? Container(
                width: size.width,
                height: size.height - (size.height * .15),
                padding: EdgeInsets.only(
                  bottom: size.height * .01,
                  right: size.width * .03,
                  left: size.width * .03,
                ),
                child: _loading
                    ? const LoadingScreen()
                    : ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (BuildContext ctx, int i) {
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: size.height * .01),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                  color: theme.themeAccent, width: 1),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  size.width * .02,
                                  size.width * .05,
                                  size.width * .02,
                                  size.width * .02),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lang.isEng()
                                        ? _services[i].englishTitle!
                                        : _services[i].arabicTitle!,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontSize: size.width * .06),
                                  ),
                                  VerticalSpace(size: size, percentage: .03),
                                  SizedBox(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: size.height * .055,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: size.width * .005),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          theme.themeAccent)),
                                              child: Text(
                                                lang.get(_services[i].active!
                                                    ? 'disable'
                                                    : 'enable'),
                                                style: TextStyle(
                                                    color:
                                                        theme.swapBackground(),
                                                    fontSize: size.width * .03),
                                              ),
                                              onPressed: () =>
                                                  _serviceStatusSubmit(
                                                      auth,
                                                      db,
                                                      lang,
                                                      _services[i].id!,
                                                      i,
                                                      !_services[i].active!),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: size.height * .055,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: size.width * .005),
                                            child: TextButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(theme
                                                                .themeAccent)),
                                                child: Text(
                                                  lang.get('edit'),
                                                  style: TextStyle(
                                                      color: theme
                                                          .swapBackground(),
                                                      fontSize:
                                                          size.width * .03),
                                                ),
                                                onPressed: () {
                                                  avc.editedService =
                                                      _services[i];
                                                  avc.setShowingEditScreen(
                                                      true);
                                                }),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            height: size.height * .055,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: size.width * .005),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          theme.themeAccent)),
                                              child: Text(
                                                lang.get('delete'),
                                                style: TextStyle(
                                                    color:
                                                        theme.swapBackground(),
                                                    fontSize: size.width * .03),
                                              ),
                                              onPressed: () async {
                                                bool delete = await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext ctx) {
                                                      return ConfirmDialog(
                                                          size: size,
                                                          lang: lang,
                                                          theme: theme);
                                                    });
                                                if (delete) {
                                                  _serviceDeleteSubmit(
                                                      auth,
                                                      db,
                                                      storage,
                                                      lang,
                                                      _services[i].id!,
                                                      i);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
              )
            : Center(
                child: Text(
                  lang.get('no_services'),
                  style: TextStyle(fontSize: size.width * .05),
                ),
              )
        : const LoadingScreen();
  }
}
