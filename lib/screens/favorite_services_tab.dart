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
import '../widgets/horizontal_space.dart';
import 'chat.dart';
import 'loading.dart';

class FavoriteServicesTab extends StatefulWidget {
  const FavoriteServicesTab({Key? key}) : super(key: key);

  @override
  _FavoriteServicesTabState createState() => _FavoriteServicesTabState();
}

class _FavoriteServicesTabState extends State<FavoriteServicesTab> {
  List<ServiceModel>? _services;

  Future<void> _getFavorites() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    _services = db.services
        .where((element) => db.favorites.contains(element.id))
        .toList();
    print(_services!.length);
    setState(() {});
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
    _getFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return avc.isShowingServiceOverviewScreen
        ? ServiceOverview(service: avc.overviewedService)
        : avc.isShowingChatScreen
            ? Chat(chatData: avc.overviewedChatData)
            : avc.isShowingSellerOverviewScreen
                ? SellerOverviewScreen(seller: avc.overviewedSeller!)
                : _services != null
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * .01,
                            vertical: size.height * .01),
                        child: _services!.isNotEmpty
                            ? ListView.builder(
                                itemCount: _services!.length,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () {
                                      avc.overviewedService = _services![i];
                                      avc.setShowingServiceOverviewScreen(true);
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
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: size.width * .3,
                                                height: size.height * .12,
                                                alignment: Alignment.center,
                                                color: const Color(0x59DEDEDE),
                                                child: Image.network(
                                                  _services![i].images![0],
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
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      lang.isEng()
                                                          ? _services![i]
                                                              .englishTitle!
                                                          : _services![i]
                                                              .arabicTitle!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              size.width * .035,
                                                          color: Colors.black),
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
                                                          rating: _services![i]
                                                              .rate!,
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              Icon(
                                                            theme.isIOS()
                                                                ? CupertinoIcons
                                                                    .star_fill
                                                                : Icons.star,
                                                            color: Colors.amber,
                                                          ),
                                                          unratedColor:
                                                              Colors.grey,
                                                          itemCount: 5,
                                                          itemSize:
                                                              size.width * .04,
                                                          direction:
                                                              Axis.horizontal,
                                                        ),
                                                        HorizontalSpace(
                                                            size: size,
                                                            percentage: .01),
                                                        Text(
                                                          _services![i]
                                                              .ratersCount
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      .03,
                                                              color:
                                                                  Colors.black),
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
                                                          _services![i].price!,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  size.width *
                                                                      .04,
                                                              color:
                                                                  Colors.black),
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
                                                              color:
                                                                  Colors.black),
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
                                                                  _services![i]
                                                                      .id!)) {
                                                            setState(() {
                                                              db.favorites
                                                                  .remove(
                                                                      _services![
                                                                              i]
                                                                          .id!);
                                                            });
                                                          } else {
                                                            setState(() {
                                                              db.favorites.add(
                                                                  _services![i]
                                                                      .id!);
                                                            });
                                                          }
                                                          _editFavorite();
                                                        },
                                                        child: Icon(
                                                          theme.isIOS()
                                                              ? CupertinoIcons
                                                                  .heart_fill
                                                              : Icons.favorite,
                                                          size:
                                                              size.width * .06,
                                                          color: db.favorites
                                                                  .contains(
                                                                      _services![
                                                                              i]
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
                                child: Text(lang.get("no_favorites_services")),
                              ),
                      )
                    : const LoadingScreen();
  }
}
