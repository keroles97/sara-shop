import 'dart:async';
import 'dart:convert';

import 'package:app/models/chat_users_list_model.dart';
import 'package:app/models/message_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/horizontal_space.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/http_exception_model.dart';
import '../providers/app_view_controller_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/snack_bar.dart';
import 'loading.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key, required this.chatData}) : super(key: key);
  final ChatUsersListModel? chatData;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late ChatUsersListModel? _chatData;
  final TextEditingController _textController = TextEditingController();
  bool _loading = true;
  final List<MessageModel> _messages = [];
  StreamSubscription<http.StreamedResponse>? _messagesSubscription;
  StreamSubscription<List<int>>? _messagesSubscription1;

  Future<void> sendMessage(LanguageProvider lang) async {
    try {
      if (_textController.text
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .isEmpty) {
        snackBar(context, lang, 'empty');
        return;
      }
      final db = Provider.of<DatabaseProvider>(context, listen: false);
      MessageModel message = MessageModel(
          senderUid: db.user.uId,
          body: _textController.text,
          date: {".sv": "timestamp"});
      await db.post(
          'chatChannels/${_chatData!.chatChannel}/_messages', message.toMap());
      db.put(
          'chatChannels/${_chatData!.chatChannel}/data/unreadCount/${_chatData!.uid}',
          {
            ".sv": {"increment": 1},
          });
      db.put('chatChannels/${_chatData!.chatChannel}/data/lastMessageDate',
          {".sv": "timestamp"});
      _textController.clear();
    } catch (error) {
      showInfoAlertDialog(context, lang, 'unknown_error', true);
    }
  }

  Future<void> getMessages() async {
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    try {
      final request = http.Request(
          "GET",
          Uri.parse(db.databaseApi(
              'chatChannels/${_chatData!.chatChannel}/_messages')));
      //request.headers["Cache-Control"] = "no-cache";
      request.headers["Accept"] = "text/event-stream";
      final Future<http.StreamedResponse> res = http.Client().send(request);

      _messagesSubscription = res.asStream().listen((event) {
        _messagesSubscription1 = event.stream.listen((value) {
          if (!utf8.decode(value).contains('null')) {
            final resData = json.decode(utf8.decode(value.sublist(17)));
            if (resData['path'].toString().length > 2) {
              _messages.insert(
                  0,
                  MessageModel.fromJson(
                      Map<String, dynamic>.from(resData['data'])));
            } else {
              resData['data'].values.forEach((e) {
                _messages.insert(
                    0, MessageModel.fromJson(Map<String, dynamic>.from(e)));
              });
            }
            //_messages.sort((a, b) => b.date!.toString().compareTo(a.date!.toString()));
            setState(() {});
          }
        });
      });
      db.put(
          'chatChannels/${_chatData!.chatChannel}/data/unreadCount/${db.user.uId}',
          0);
    } on HttpException catch (error) {
      if (kDebugMode) {
        print('service_status_submit: ' + error.toString());
      }
      showInfoAlertDialog(context, lang, 'unknown_error', true);
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

  @override
  void initState() {
    _chatData = widget.chatData;

    getMessages();
    super.initState();
  }

  @override
  void dispose() {
    if (_messagesSubscription != null) {
      _messagesSubscription!.cancel();
    }
    if (_messagesSubscription1 != null) {
      _messagesSubscription1!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final appViewController =
        Provider.of<AppViewControllerProvider>(context, listen: true);
    final lang = Provider.of<LanguageProvider>(context, listen: true);
    final theme = Provider.of<ThemeProvider>(context, listen: true);
    final db = Provider.of<DatabaseProvider>(context, listen: true);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * .05),
        child: Container(
            height: size.height * .05,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: size.width * .04),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: lang.isEng() ? 3 : null,
                  right: lang.isEng() ? null : 3,
                  child: InkWell(
                      onTap: () {
                        appViewController.setShowingChatScreen(false);
                      },
                      child: Icon(
                        theme.isIOS() ? CupertinoIcons.back : Icons.arrow_back,
                        color: theme.themeAccent,
                        size: size.height * .03,
                      )),
                ),
                HorizontalSpace(size: size, percentage: .03),
                Center(
                  child: Text(
                    _chatData!.name!,
                    style: TextStyle(fontSize: size.width * .05),
                  ),
                )
              ],
            )),
      ),
      body: Container(
        width: size.width,
        height: size.height - (size.height * .15),
        padding: EdgeInsets.symmetric(horizontal: size.width * .02),
        child: _loading
            ? const LoadingScreen()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        margin:
                            EdgeInsets.symmetric(horizontal: size.width * .02),
                        child: ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: _messages.length,
                            itemBuilder: (BuildContext ctx, int i) {
                              return Container(
                                alignment: _messages[i].senderUid == db.user.uId
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * .01,
                                  vertical: size.height * .01,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: size.width * .6,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(size.width * .02),
                                      decoration: BoxDecoration(
                                          color: _messages[i].senderUid ==
                                                  db.user.uId
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        _messages[i].body!,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * .04),
                                      ),
                                    ),
                                    VerticalSpace(
                                        size: size, percentage: 0.005),
                                    Container(
                                      width: size.width * .6,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * .03,
                                      ),
                                      alignment:
                                          _messages[i].senderUid == db.user.uId
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                      child: Text(
                                        formatDateTime(_messages[i].date!),
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: size.width * .03),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: size.width * .01),
                    height: size.height * .1,
                    width: size.width,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: size.width * .77,
                          height: size.height * .07,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            textAlign:
                                lang.isEng() ? TextAlign.left : TextAlign.right,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * .02),
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.all(size.width * .02),
                                border: InputBorder.none,
                                hintText: lang.get("message_hint")),
                          ),
                        ),
                        // HorizontalSpace(size: size, percentage: .01),
                        InkWell(
                          onTap: () => sendMessage(lang),
                          child: Container(
                            width: size.width * .13,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: theme.themeAccent,
                                shape: BoxShape.circle),
                            child: Icon(
                              lang.isEng()
                                  ? theme.isIOS()
                                      ? CupertinoIcons
                                          .arrowshape_turn_up_right_fill
                                      : Icons.send
                                  : theme.isIOS()
                                      ? CupertinoIcons
                                          .arrowshape_turn_up_left_fill
                                      : Icons.send,
                              color: Colors.white,
                              size: size.width * 0.05,
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
  }
}
