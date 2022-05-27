import 'package:app/models/chat_users_list_model.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/loading.dart';
import 'package:app/widgets/cus_divider.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../providers/app_view_controller_provider.dart';
import '../providers/database_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/date_time_format.dart';
import '../utils/info_alert_dialog.dart';

class ChatSupport extends StatefulWidget {
  const ChatSupport({Key? key}) : super(key: key);

  @override
  State<ChatSupport> createState() => _ChatSupportState();
}

class _ChatSupportState extends State<ChatSupport> {
  final List<ChatUsersListModel> _chats = [];
  bool _loading = true;

  String _subString(String text) {
    if (text.length > 50) {
      return text.substring(0, 50);
    }
    return text;
  }

  // Future<void> _getData() async {
  //   final db = Provider.of<DatabaseProvider>(context, listen: false);
  //   final auth = Provider.of<AuthProvider>(context, listen: false);
  //   final lang = Provider.of<LanguageProvider>(context, listen: false);
  //   final res = await db.get('users/:uid/sharedChats');
  //   try {
  //     if (res == null) {
  //       setState(() {
  //         _loading = false;
  //       });
  //       return;
  //     }
  //     final data = res as Map<dynamic, dynamic>;
  //     int i = 0;
  //     data.forEach((k0, v0) async {
  //       i++;
  //       final name = await db.get('users/$k0/name');
  //
  //       (v0 as Map<dynamic, dynamic>).forEach((k1, v1) async {
  //         final serviceId = k1;
  //         final chatChannel = v1["chatChannel"];
  //         final chatChannelData =
  //             await db.get('chatChannels/$chatChannel/data');
  //         final unreadCount = chatChannelData['unreadCount'][db.user.uId] ?? 0;
  //         final lastMessageDate = chatChannelData['lastMessageDate'];
  //         final service = await db.get('services/$serviceId');
  //         final serviceEngTitle = service['englishTitle'];
  //         final serviceAraTitle = service['arabicTitle'];
  //         _chats.add(ChatUsersListModel(
  //           uid: k0,
  //           name: name,
  //           chatChannel: chatChannel,
  //           unreadCount: unreadCount,
  //           lastMessageDate: lastMessageDate,
  //           englishTitle: serviceEngTitle,
  //           arabicTitle: serviceAraTitle,
  //         ));
  //       });
  //       if (data.length == i) {
  //         _chats.sort((a, b) => double.parse(b.lastMessageDate!.toString())
  //             .compareTo(double.parse(a.lastMessageDate!.toString())));
  //         setState(() {
  //           _loading = false;
  //         });
  //       }
  //     });
  //   } on HttpException catch (error) {
  //     if (kDebugMode) {
  //       print('chat_support_getData: ' + error.toString());
  //     }
  //     showInfoAlertDialog(
  //         context, lang, auth.handleAuthenticationError(error), true);
  //   } catch (error) {
  //     if (kDebugMode) {
  //       print('chat_support_getData: ' + error.toString());
  //     }
  //     showInfoAlertDialog(context, lang, 'unknown_error', true);
  //   }
  // }

  Future<void> _getData() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final res = await db.get('users/:uid/sharedChats');
    try {
      if (res == null) {
        setState(() {
          _loading = false;
        });
        return;
      }
      final data = res as Map<dynamic, dynamic>;

      for (MapEntry e0 in data.entries) {
        final name = await db.get('users/${e0.key}/name');

        for (MapEntry e1 in (e0.value as Map<dynamic, dynamic>).entries) {
          final serviceId = e1.key;
          final chatChannel = e1.value["chatChannel"];
          final chatChannelData =
              await db.get('chatChannels/$chatChannel/data');
          final unreadCount = chatChannelData['unreadCount'][db.user.uId] ?? 0;
          final lastMessageDate = chatChannelData['lastMessageDate'];
          final service = await db.get('services/$serviceId');
          final serviceEngTitle = service['englishTitle'];
          final serviceAraTitle = service['arabicTitle'];
          _chats.add(ChatUsersListModel(
            uid: e0.key,
            name: name,
            chatChannel: chatChannel,
            unreadCount: unreadCount,
            lastMessageDate: lastMessageDate,
            englishTitle: serviceEngTitle,
            arabicTitle: serviceAraTitle,
          ));
        }
      }

      _chats.sort((a, b) => double.parse(b.lastMessageDate!.toString())
          .compareTo(double.parse(a.lastMessageDate!.toString())));
      setState(() {
        _loading = false;
      });
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('chat_support_getData: ' + error.toString());
      }
      showInfoAlertDialog(
          context, lang, auth.handleAuthenticationError(error), true);
    } catch (error) {
      if (kDebugMode) {
        print('chat_support_getData: ' + error.toString());
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
    return _loading
        ? const LoadingScreen()
        : _chats.isNotEmpty
            ? Container(
                width: size.width,
                height: size.height - (size.height * .15),
                padding: EdgeInsets.only(
                  bottom: size.height * .01,
                  right: size.width * .03,
                  left: size.width * .03,
                ),
                child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (BuildContext ctx, int i) {
                      return InkWell(
                        onTap: () async {
                          avc.overviewedChatData = _chats[i];
                          avc.setShowingChatScreen(true);
                        },
                        child: Container(
                          width: size.width * .95,
                          height: size.height * .15,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * .02,
                              vertical: size.height * .01),
                          margin:
                              EdgeInsets.symmetric(vertical: size.height * .01),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            border:
                                Border.all(color: theme.themeAccent, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width * .65,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * .01),
                                      child: Text(
                                        _chats[i].name!,
                                        style: TextStyle(
                                            fontSize: size.height * .022),
                                      ),
                                    ),
                                    CusDivider(
                                        size: size,
                                        widthPercent: 0.8,
                                        color: theme.themeAccent),
                                    VerticalSpace(size: size, percentage: .02),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * .01),
                                      child: Text(
                                        _subString(lang.isEng()
                                            ? _chats[i].englishTitle!
                                            : _chats[i].arabicTitle!),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: size.height * .022),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: size.width * .15,
                                padding: EdgeInsets.symmetric(
                                    vertical: size.height * .006),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _chats[i].unreadCount != 0
                                        ? Container(
                                            alignment: Alignment.center,
                                            height: size.height * 0.03,
                                            padding: EdgeInsets.all(
                                                size.width * .02),
                                            margin: EdgeInsets.all(
                                                size.width * .01),
                                            decoration: BoxDecoration(
                                                color: theme.themeAccent,
                                                shape: BoxShape.circle),
                                            child: Text(
                                              _chats[i].unreadCount.toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: size.width * .03),
                                            ),
                                          )
                                        : const SizedBox(),
                                    Text(
                                      formatDateTime(_chats[i].lastMessageDate!)
                                          .replaceFirst(',', ''),
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: size.width * .03),
                                    )
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
                child: Text(lang.get("no_chats")),
              );
  }
}
