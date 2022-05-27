import 'package:app/models/ad_model.dart';
import 'package:app/screens/chat.dart';
import 'package:app/screens/seller_overview.dart';
import 'package:app/screens/service_overview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../widgets/carousel.dart';
import '../widgets/horizontal_space.dart';
import 'loading.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({Key? key}) : super(key: key);

  @override
  _ServicesTabState createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  final TextEditingController _searchController = TextEditingController();
  final List<ServiceModel> _filteredServices = [];
  String _searchText = "";
  bool _servicesLoaded = false;
  bool _favoritesLoaded = false;
  bool _adsLoaded = false;

  void prepareServicesToView(dynamic services, dynamic disabledUsers) {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    List<String> disUsers = [];
    if (disabledUsers != null) {
      for (var e in disabledUsers.keys) {
        disUsers.add(e.toString());
      }
    }
    if (services != null) {
      for (var e in services.values) {
        if (disUsers.contains(e["sellerUid"])) continue;
        db.services.add(ServiceModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    setState(() {
      _filteredServices.addAll(db.services);
      _servicesLoaded = true;
    });
  }

  void prepareFavoritesToView(dynamic data) {
    if (data != null) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .favorites
          .addAll(data);
    }
    setState(() {
      _favoritesLoaded = true;
    });
  }

  Future<void> _search(String text) async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    _filteredServices.clear();
    _filteredServices.addAll(db.services
        .where((element) =>
            element.englishKeyWords!.contains(text) ||
            element.arabicKeyWords!.contains(text))
        .toList());
    setState(() {});
  }

  Future<void> _getServices() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (db.services.isNotEmpty) {
      setState(() {
        _filteredServices.addAll(db.services);
        _servicesLoaded = true;
      });
      return;
    }
    try {
      final data = await db.get('services', '&orderBy="active"&equalTo=true');
      final disabledUsers = await _getDisabledUsers();
      prepareServicesToView(data, disabledUsers);
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

  Future<void> _getFavorites() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (db.favorites.isNotEmpty) {
      setState(() {
        _favoritesLoaded = true;
      });
      return;
    }
    try {
      final data = await db.get('favorites/:uid');
      prepareFavoritesToView(data);
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

  Future<dynamic> _getDisabledUsers() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final data = await db.get('users', '&orderBy="active"&equalTo=false');
      return data;
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

  Future<void> _getAds() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (db.ads.isNotEmpty) {
      setState(() {
        _adsLoaded = true;
      });
      return;
    }
    try {
      final data = await db.get('ads');
      if (data == null) return;
      for (var e in data) {
        db.ads.add(AdModel.fromJson(Map<String, dynamic>.from(e)));
      }
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('_getAds_http: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('_getAds: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    } finally {
      setState(() {
        _adsLoaded = true;
      });
    }
  }

  @override
  void initState() {
    _searchController.addListener(() {});
    _getAds();
    _getFavorites();
    _getServices();

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return Scaffold(
        body: avc.isShowingServiceOverviewScreen
            ? ServiceOverview(service: avc.overviewedService)
            : avc.isShowingChatScreen
                ? Chat(chatData: avc.overviewedChatData)
                : avc.isShowingSellerOverviewScreen
                    ? SellerOverviewScreen(seller: avc.overviewedSeller!)
                    : _servicesLoaded && _favoritesLoaded && _adsLoaded
                        ? NestedScrollView(
                            headerSliverBuilder:
                                (BuildContext context, bool innerBoxScrolled) {
                              return <Widget>[
                                Carousel(
                                    list: db.ads,
                                    size: size,
                                    lang: lang,
                                    theme: theme),
                                searchWidget(size, db, theme, lang)
                              ];
                            },
                            body: _filteredServices.isNotEmpty
                                ? Container(
                                    margin: EdgeInsets.all(size.width * .01),
                                    child: ListView.builder(
                                        itemCount: _filteredServices.length,
                                        itemBuilder: (context, i) {
                                          return InkWell(
                                            onTap: () {
                                              avc.overviewedService =
                                                  _filteredServices[i];
                                              avc.setShowingServiceOverviewScreen(
                                                  true);
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
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: size.width * .3,
                                                        height:
                                                            size.height * .12,
                                                        alignment:
                                                            Alignment.center,
                                                        color: const Color(
                                                            0x59DEDEDE),
                                                        child: Image.network(
                                                          _filteredServices[i]
                                                              .images![0],
                                                          width:
                                                              size.width * .25,
                                                          height:
                                                              size.height * .11,
                                                          fit: BoxFit.contain,
                                                          filterQuality:
                                                              FilterQuality.low,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    size.width *
                                                                        .02),
                                                        width: size.width * .58,
                                                        height:
                                                            size.height * .12,
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
                                                                  ? _filteredServices[
                                                                          i]
                                                                      .englishTitle!
                                                                  : _filteredServices[
                                                                          i]
                                                                      .arabicTitle!,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      size.width *
                                                                          .035,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                RatingBarIndicator(
                                                                  rating:
                                                                      _filteredServices[
                                                                              i]
                                                                          .rate!,
                                                                  itemBuilder:
                                                                      (context,
                                                                              i) =>
                                                                          Icon(
                                                                    theme.isIOS()
                                                                        ? CupertinoIcons
                                                                            .star_fill
                                                                        : Icons
                                                                            .star,
                                                                    color: Colors
                                                                        .amber,
                                                                  ),
                                                                  unratedColor:
                                                                      Colors
                                                                          .grey,
                                                                  itemCount: 5,
                                                                  itemSize:
                                                                      size.width *
                                                                          .04,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                ),
                                                                HorizontalSpace(
                                                                    size: size,
                                                                    percentage:
                                                                        .01),
                                                                Text(
                                                                  _filteredServices[
                                                                          i]
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
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  _filteredServices[
                                                                          i]
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
                                                                    percentage:
                                                                        .01),
                                                                Text(
                                                                  lang.get(
                                                                      "sar"),
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
                                                            top: size.height *
                                                                .006),
                                                        height:
                                                            size.height * .13,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            InkWell(
                                                                onTap: () {
                                                                  if (db
                                                                      .favorites
                                                                      .contains(
                                                                          _filteredServices[i]
                                                                              .id!)) {
                                                                    setState(
                                                                        () {
                                                                      db.favorites
                                                                          .remove(
                                                                              _filteredServices[i].id!);
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      db.favorites.add(
                                                                          _filteredServices[i]
                                                                              .id!);
                                                                    });
                                                                  }
                                                                  _editFavorite();
                                                                },
                                                                child: Icon(
                                                                  theme.isIOS()
                                                                      ? CupertinoIcons
                                                                          .heart_fill
                                                                      : Icons
                                                                          .favorite,
                                                                  size:
                                                                      size.width *
                                                                          .06,
                                                                  color: db
                                                                          .favorites
                                                                          .contains(_filteredServices[i]
                                                                              .id!)
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .grey,
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
                                        }),
                                  )
                                : Center(
                                    child: Text(lang.get("no_services")),
                                  ))
                        : const LoadingScreen());
  }

  SliverAppBar searchWidget(Size size, DatabaseProvider db, ThemeProvider theme,
      LanguageProvider lang) {
    return SliverAppBar(
      toolbarHeight: size.height * .08,
      backgroundColor: theme.themeAccent,
      pinned: true,
      title: Container(
        margin: EdgeInsets.symmetric(
            horizontal: size.width * .01, vertical: size.width * .0),
        height: size.height * .07,
        alignment: Alignment.center,
        child: IntrinsicHeight(
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: theme.darkBackground, fontSize: size.width * 0.04),
            maxLines: 1,
            decoration: InputDecoration(
              hintText: lang.get("search"),
              hintStyle: const TextStyle(color: Color(0xffC4C6CC)),
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                size.width * .01,
                size.height * .015,
                size.width * .01,
                size.height * .015,
              ),
              prefixIcon: Icon(
                theme.isIOS() ? CupertinoIcons.search : Icons.search,
                size: size.width * 0.04,
                color: Colors.black,
              ),
              suffixIcon: _searchText.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _filteredServices.clear();
                          _filteredServices.addAll(db.services);
                          _searchText = "";
                        });
                      },
                      child: Icon(
                        theme.isIOS() ? CupertinoIcons.clear : Icons.clear,
                        size: size.width * 0.04,
                        color: Colors.black,
                      ),
                    )
                  : null,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  )),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  )),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  )),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _filteredServices.clear();
                  _filteredServices.addAll(db.services);
                }
                _searchText = value;
              });
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _search(value);
              }
            },
          ),
        ),
      ),
    );
  }
}
