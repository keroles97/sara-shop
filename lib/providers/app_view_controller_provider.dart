import 'package:app/models/chat_users_list_model.dart';
import 'package:app/models/service_model.dart';
import 'package:app/models/user_model.dart';
import 'package:flutter/material.dart';

class AppViewControllerProvider with ChangeNotifier {
  // show and hide service overview screen
  ServiceModel? overviewedService;
  bool isShowingServiceOverviewScreen = false;

  setShowingServiceOverviewScreen(bool value) {
    isShowingServiceOverviewScreen = value;
    notifyListeners();
  }

/////////////////////////////////////////////////////////////////////////////
  // show and hide seller overview screen
  UserModel? overviewedSeller;
  bool isShowingSellerOverviewScreen = false;

  setShowingSellerOverviewScreen(bool value) {
    isShowingSellerOverviewScreen = value;
    notifyListeners();
  }

/////////////////////////////////////////////////////////////////////////////

  // show and hide service edit screen
  ServiceModel? editedService;
  bool isShowingEditScreen = false;

  setShowingEditScreen(bool value) {
    isShowingEditScreen = value;
    notifyListeners();
  }

/////////////////////////////////////////////////////////////////////////////
  // show and hide favorite chat screen
  ChatUsersListModel? overviewedChatData;
  bool isShowingChatScreen = false;

  setShowingChatScreen(bool value) {
    isShowingChatScreen = value;
    notifyListeners();
  }
}
