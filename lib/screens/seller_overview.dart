import 'package:app/models/user_model.dart';
import 'package:app/utils/snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../models/service_model.dart';
import '../providers/app_view_controller_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import '../widgets/horizontal_space.dart';
import '../widgets/vertical_space.dart';
import 'loading.dart';

class SellerOverviewScreen extends StatefulWidget {
  const SellerOverviewScreen({Key? key, required this.seller})
      : super(key: key);
  final UserModel seller;

  @override
  _SellerOverviewScreenState createState() => _SellerOverviewScreenState();
}

class _SellerOverviewScreenState extends State<SellerOverviewScreen> {
  UserModel? _seller;
  final List<ServiceModel> _services = [];
  bool _servicesLoaded = false;

  Future<void> _getServices() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    try {
      final data = await db.get(
          'services', '&orderBy="sellerUid"&equalTo="${_seller!.uId}"');
      if (data != null) {
        for (var e in data.values) {
          final service = ServiceModel.fromJson(Map<String, dynamic>.from(e));
          if (service.active!) {
            _services.add(service);
          }
        }
      }
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
    } finally {
      setState(() {
        _servicesLoaded = true;
      });
    }
  }

  Future<void> _editFavorite() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      db.favorites.isNotEmpty
          ? await db.put('favorites/:uid', db.favorites)
          : await db.delete('favorites/:uid');
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
    _seller = widget.seller;
    _getServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return _servicesLoaded
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(size.height * .05),
              child: Container(
                  alignment: lang.isEng()
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      avc.setShowingSellerOverviewScreen(false);
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        size.width * .04,
                        size.height * .01,
                        size.width * .06,
                        size.height * .0,
                      ),
                      child: Icon(
                        theme.isIOS() ? CupertinoIcons.back : Icons.arrow_back,
                        color: theme.themeAccent,
                      ),
                    ),
                  )),
            ),
            body: SingleChildScrollView(
              child: Container(
                width: size.width,
                padding: EdgeInsets.symmetric(
                    vertical: size.height * .02, horizontal: size.width * .01),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _seller!.name!,
                          style: TextStyle(fontSize: size.width * .05),
                        ),
                        VerticalSpace(size: size, percentage: 0.01),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: _seller!.email));
                            snackBar(context, lang, "copy");
                          },
                          child: Text(
                            _seller!.email!,
                            style: TextStyle(fontSize: size.width * .05),
                          ),
                        ),
                        VerticalSpace(size: size, percentage: 0.01),
                        RatingBarIndicator(
                          rating: _seller!.rate,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          unratedColor: Colors.grey,
                          itemCount: 5,
                          itemSize: size.width * .06,
                          direction: Axis.horizontal,
                        ),
                        SizedBox(
                          width: size.width * .28,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _seller!.rate.toString(),
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: size.height * .017),
                              ),
                              Text(
                                _seller!.ratersCount.toString(),
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: size.height * .017),
                              )
                            ],
                          ),
                        ),
                        VerticalSpace(size: size, percentage: 0.03),
                        SizedBox(
                          height: size.height * .8,
                          child: _services.isNotEmpty
                              ? ListView.builder(
                                  itemCount: _services.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        avc.overviewedService =
                                            _services[index];
                                        avc.setShowingServiceOverviewScreen(
                                            true);
                                        avc.setShowingSellerOverviewScreen(
                                            false);
                                      },
                                      child: Card(
                                        clipBehavior: Clip.hardEdge,
                                        elevation: 10,
                                        child: Container(
                                          height: size.height * .13,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: size.width * .27,
                                                  height: size.height * .13,
                                                  alignment: Alignment.center,
                                                  color:
                                                      const Color(0x59DEDEDE),
                                                  child: Image.network(
                                                    _services[index].images![0],
                                                    width: size.width * .25,
                                                    height: size.height * .11,
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality.low,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * .02),
                                                  width: size.width * .58,
                                                  height: size.height * .13,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        lang.isEng()
                                                            ? _services[index]
                                                                .englishTitle!
                                                            : _services[index]
                                                                .arabicTitle!,
                                                        style: TextStyle(
                                                            fontSize:
                                                                size.width *
                                                                    .035,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          RatingBarIndicator(
                                                            rating:
                                                                _services[index]
                                                                    .rate!,
                                                            itemBuilder:
                                                                (context,
                                                                        index) =>
                                                                    const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            unratedColor:
                                                                Colors.grey,
                                                            itemCount: 5,
                                                            itemSize:
                                                                size.width *
                                                                    .04,
                                                            direction:
                                                                Axis.horizontal,
                                                          ),
                                                          HorizontalSpace(
                                                              size: size,
                                                              percentage: .01),
                                                          Text(
                                                            _services[index]
                                                                .ratersCount
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    size.width *
                                                                        .03,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            _services[index]
                                                                .price!,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    size.width *
                                                                        .04,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          HorizontalSpace(
                                                              size: size,
                                                              percentage: .01),
                                                          Text(
                                                            lang.get("sar"),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    size.width *
                                                                        .03,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: size.height * .006),
                                                  height: size.height * .13,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      InkWell(
                                                          onTap: () {
                                                            if (db.favorites
                                                                .contains(
                                                                    _services[
                                                                            index]
                                                                        .id!)) {
                                                              setState(() {
                                                                db.favorites.remove(
                                                                    _services[
                                                                            index]
                                                                        .id!);
                                                              });
                                                            } else {
                                                              setState(() {
                                                                db.favorites.add(
                                                                    _services[
                                                                            index]
                                                                        .id!);
                                                              });
                                                            }
                                                            _editFavorite();
                                                          },
                                                          child: Icon(
                                                            Icons.favorite,
                                                            size: size.width *
                                                                .06,
                                                            color: db.favorites
                                                                    .contains(
                                                                        _services[index]
                                                                            .id!)
                                                                ? Colors.red
                                                                : Colors.grey,
                                                          )),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                              : Center(
                                  child: Text(lang.get("no_services")),
                                ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : const LoadingScreen();
  }
}
