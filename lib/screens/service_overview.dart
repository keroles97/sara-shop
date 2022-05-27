import 'package:app/screens/loading.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_users_list_model.dart';
import '../models/http_exception_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../providers/app_view_controller_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/info_alert_dialog.dart';
import '../widgets/vertical_space.dart';

class ServiceOverview extends StatefulWidget {
  const ServiceOverview({Key? key, required this.service}) : super(key: key);
  final ServiceModel? service;

  @override
  _ServiceOverviewState createState() => _ServiceOverviewState();
}

class _ServiceOverviewState extends State<ServiceOverview> {
  ServiceModel? _service;
  UserModel? _seller;
  ChatUsersListModel? _chatData;
  int _carouselIndex = 0;
  double _tempRate = 0.0;
  double _myRate = 0.0;
  bool _sellerLoaded = false;
  bool _myRateLoaded = false;
  bool _loadingRate = false;
  bool _loadingChat = false;

  Future<void> _getChatData() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _loadingChat = true;
    });
    try {
      dynamic chatChannel = await db.get(
          'users/:uid/sharedChats/${_seller!.uId}/${_service!.id}/chatChannel');

      if (chatChannel == null) {
        chatChannel = (await db.post('chatChannels', {
          "data": {
            "serviceId": _service!.id,
            "unreadCount": {"${db.user.uId}": 0, "${_seller!.uId}": 0}
          }
        }))['name'];
        await db.put(
            'users/${db.user.uId}/sharedChats/${_seller!.uId}/${_service!.id}/chatChannel',
            chatChannel);
        await db.put(
            'users/${_seller!.uId}/sharedChats/${db.user.uId}/${_service!.id}/chatChannel',
            chatChannel);
      }
      _chatData = ChatUsersListModel(
          uid: _seller!.uId,
          name: _seller!.name,
          chatChannel: chatChannel,
          englishTitle: '',
          arabicTitle: '',
          unreadCount: 0);
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('service_oveview_getChatData: ' + error.toString());
      }
      showInfoAlertDialog(
          context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('service_oveview_getChatData: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    } finally {
      setState(() {
        _loadingChat = false;
      });
    }
  }

  Future<void> _rate() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _loadingRate = true;
    });
    try {
      _seller!.rate = double.parse(
          (((_seller!.rate * _seller!.ratersCount) + _myRate) /
                  (_seller!.ratersCount + 1))
              .toStringAsFixed(1));
      _seller!.ratersCount++;

      _service!.rate = double.parse(
          (((_service!.rate! * _service!.ratersCount!) + _myRate) /
                  (_service!.ratersCount! + 1))
              .toStringAsFixed(1));
      _service!.ratersCount = _service!.ratersCount! + 1;

      await db.put('users/${_seller!.uId}', _seller!.toMap());
      await db.put('services/${_service!.id}', _service!.toMap());
      await db.put('ratings/:uid/${_service!.id}', _myRate);
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
        _loadingRate = false;
      });
    }
  }

  Future<void> _getSellerData() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final data = await db.get('users/${_service!.sellerUid}');
      _seller = UserModel.fromJson(Map<String, dynamic>.from(data));
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
        _sellerLoaded = true;
      });
    }
  }

  Future<void> _getMyRate() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final data = await db.get('ratings/:uid/${_service!.id}');
      if (data != null) {
        _myRate = double.parse(data.toString());
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
        _myRateLoaded = true;
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
    _service = widget.service;

    _getSellerData();
    _getMyRate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final avc = Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return _loadingChat
        ? const LoadingScreen()
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(size.height * .05),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * .03),
                  alignment: lang.isEng()
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      avc.setShowingServiceOverviewScreen(false);
                    },
                    child: Icon(
                      theme.isIOS() ? CupertinoIcons.back : Icons.arrow_back,
                      size: size.width * .06,
                      color: theme.themeAccent,
                    ),
                  )),
            ),
            floatingActionButton: _service!.sellerUid == db.user.uId
                ? null
                : FloatingActionButton(
                    child: Icon(
                      theme.isIOS()
                          ? CupertinoIcons.chat_bubble_text_fill
                          : Icons.chat,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await _getChatData();
                      avc.overviewedChatData = _chatData;
                      avc.setShowingChatScreen(true);
                      avc.setShowingServiceOverviewScreen(false);
                    },
                  ),
            body: _sellerLoaded && _myRateLoaded
                ? SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                          top: size.height * .02, bottom: size.height * .05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                    height: size.height * .3,
                                    autoPlay: true,
                                    initialPage: 0,
                                    autoPlayInterval:
                                        const Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        const Duration(milliseconds: 1500),
                                    autoPlayCurve: Curves.easeInOutQuad,
                                    enableInfiniteScroll: true,
                                    disableCenter: true,
                                    pauseAutoPlayOnManualNavigate: true,
                                    pauseAutoPlayOnTouch: true,
                                    viewportFraction: 1,
                                    onPageChanged: (i, r) {
                                      setState(() {
                                        _carouselIndex = i;
                                      });
                                    }),
                                items: _service!.images!.map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Image.network(
                                        i,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                              Container(
                                alignment: Alignment.center,
                                height: size.width * .05,
                                margin: EdgeInsets.symmetric(
                                    vertical: size.height * .015),
                                child: ListView.builder(
                                    itemCount: _service!.images!.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: size.width * .02,
                                        height: size.width * .02,
                                        margin:
                                            EdgeInsets.all(size.width * .01),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _carouselIndex == index
                                                ? theme.themeAccent
                                                : Colors.grey),
                                      );
                                    }),
                              )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * .03),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                VerticalSpace(size: size, percentage: .001),
                                Divider(
                                  color: Colors.grey,
                                  height: size.height * .001,
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          if (db.favorites
                                              .contains(_service!.id!)) {
                                            setState(() {
                                              db.favorites
                                                  .remove(_service!.id!);
                                            });
                                          } else {
                                            setState(() {
                                              db.favorites.add(_service!.id!);
                                            });
                                          }
                                          _editFavorite();
                                        },
                                        child: Icon(
                                          theme.isIOS()
                                              ? CupertinoIcons.heart_fill
                                              : Icons.favorite,
                                          size: size.width * .06,
                                          color: db.favorites
                                                  .contains(_service!.id!)
                                              ? Colors.red
                                              : Colors.grey,
                                        )),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RatingBarIndicator(
                                          rating: _service!.rate!,
                                          itemBuilder: (context, index) => Icon(
                                            theme.isIOS()
                                                ? CupertinoIcons.star_fill
                                                : Icons.star,
                                            color: Colors.amber,
                                          ),
                                          unratedColor: Colors.grey,
                                          itemCount: 5,
                                          itemSize: size.width * .05,
                                          direction: Axis.horizontal,
                                        ),
                                        SizedBox(
                                          width: size.width * .22,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                _service!.rate!.toString(),
                                                style: TextStyle(
                                                    color: Colors.amber,
                                                    fontSize:
                                                        size.height * .015),
                                              ),
                                              Text(
                                                _service!.ratersCount!
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.amber,
                                                    fontSize:
                                                        size.height * .015),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Text(
                                  lang.isEng()
                                      ? _service!.englishTitle!
                                      : _service!.arabicTitle!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * .05),
                                  textAlign: TextAlign.start,
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Text(
                                  lang.isEng()
                                      ? _service!.englishDescription!
                                      : _service!.arabicDescription!,
                                  style: TextStyle(fontSize: size.width * .04),
                                  textAlign: TextAlign.start,
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _service!.price!,
                                      style: TextStyle(
                                          fontSize: size.width * .06,
                                          color: theme.themeAccent),
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      "  " + lang.get("sar"),
                                      style: TextStyle(
                                          fontSize: size.width * .03,
                                          color: theme.themeAccent),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                                VerticalSpace(size: size, percentage: .01),
                                Divider(
                                  color: Colors.grey,
                                  height: size.height * .001,
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      lang.get("seller") + ":",
                                      style: TextStyle(
                                        fontSize: size.width * .04,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        avc.overviewedSeller = _seller;
                                        avc.setShowingSellerOverviewScreen(
                                            true);
                                        avc.setShowingServiceOverviewScreen(
                                            false);
                                      },
                                      child: Text(
                                        _seller!.name!,
                                        style: TextStyle(
                                            fontSize: size.width * .04,
                                            fontWeight: FontWeight.bold,
                                            color: theme.themeAccent),
                                        textAlign: TextAlign.start,
                                      ),
                                    )
                                  ],
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Divider(
                                  color: Colors.grey,
                                  height: size.height * .001,
                                ),
                                VerticalSpace(size: size, percentage: .02),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      lang.get("service_phone") + " :",
                                      style:
                                          TextStyle(fontSize: size.width * .04),
                                      textAlign: TextAlign.start,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        launchUrl(Uri.parse(
                                            "tel:" + _service!.phone!));
                                      },
                                      child: Text(
                                        _service!.phone!,
                                        style: TextStyle(
                                            color: theme.themeAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size.width * .04),
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalSpace(size: size, percentage: .01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      lang.get("service_whatsapp") + " :",
                                      style:
                                          TextStyle(fontSize: size.width * .04),
                                      textAlign: TextAlign.start,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        launchUrl(Uri.parse(
                                            "whatsapp://send?phone=" +
                                                _service!.whatsapp!));
                                      },
                                      child: Text(
                                        _service!.whatsapp!,
                                        style: TextStyle(
                                            color: theme.themeAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size.width * .04),
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalSpace(size: size, percentage: .01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      lang.get("form_email") + " :",
                                      style:
                                          TextStyle(fontSize: size.width * .04),
                                      textAlign: TextAlign.start,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        launchUrl(Uri.parse(
                                            "mailto:" + _service!.email!));
                                      },
                                      child: Text(
                                        _service!.email!,
                                        style: TextStyle(
                                            color: theme.themeAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size.width * .04),
                                      ),
                                    ),
                                  ],
                                ),
                                VerticalSpace(size: size, percentage: .03),
                                if(_service!.sellerUid != db.user.uId)
                                _myRate == 0
                                    ? _loadingRate
                                        ? const Center(
                                            child: CircularProgressIndicator
                                                .adaptive())
                                        : Container(
                                            width: size.width,
                                            height: size.height * .05,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: size.width * .02),
                                            alignment: Alignment.center,
                                            color: theme.themeAccent,
                                            child: TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (BuildContext ctx) {
                                                        return Container(
                                                          color: theme
                                                              .getBackground(),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              RatingBar.builder(
                                                                initialRating:
                                                                    _myRate,
                                                                minRating: 1,
                                                                direction: Axis
                                                                    .horizontal,
                                                                allowHalfRating:
                                                                    true,
                                                                itemCount: 5,
                                                                itemBuilder:
                                                                    (c, _) =>
                                                                        Icon(
                                                                  theme.isIOS()
                                                                      ? CupertinoIcons
                                                                          .star_fill
                                                                      : Icons
                                                                          .star,
                                                                  color: Colors
                                                                      .amber,
                                                                ),
                                                                onRatingUpdate:
                                                                    (rate) {
                                                                  setState(() {
                                                                    _tempRate =
                                                                        rate;
                                                                  });
                                                                },
                                                              ),
                                                              VerticalSpace(
                                                                  size: size,
                                                                  percentage:
                                                                      .04),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  _myRate =
                                                                      _tempRate;
                                                                  _tempRate =
                                                                      0.0;
                                                                  _rate();
                                                                },
                                                                child: Text(
                                                                    lang.get(
                                                                        "done"),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            size.width *
                                                                                .06)),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    _tempRate =
                                                                        0.0;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  lang.get(
                                                                      "cancel"),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          size.width *
                                                                              .06),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: Text(
                                                  lang.get("rate"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          size.width * .06),
                                                )))
                                    : Center(
                                        child: RatingBarIndicator(
                                          rating: _myRate,
                                          itemBuilder: (context, index) => Icon(
                                            theme.isIOS()
                                                ? CupertinoIcons.star_fill
                                                : Icons.star,
                                            color: Colors.amber,
                                          ),
                                          unratedColor: Colors.grey,
                                          itemCount: 5,
                                          itemSize: size.width * .06,
                                          direction: Axis.horizontal,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const LoadingScreen(),
          );
  }
}
