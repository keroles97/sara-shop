import 'dart:convert';

import 'package:app/models/http_exception_model.dart';
import 'package:app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/ad_model.dart';
import '../models/service_model.dart';

class DatabaseProvider with ChangeNotifier {
  final List<ServiceModel> services = [];
  final List<dynamic> favorites = [];
  final List<AdModel> ads = [];

  UserModel _user = UserModel();
  int unreadNotificationCount = 0;
  int unreadMessagesCount = 0;

  UserModel get user => _user;

  getUserAuthData(String? uId, String? token, bool updateToken) async {
    _user.uId = uId;
    _user.token = token;
    if (user.token != null && updateToken) {
      await put('users/:uid/token', user.token!);
    }
    notifyListeners();
  }

  String _databaseApi(String path) {
    return 'https://sara-shop-ccd7d-default-rtdb.firebaseio.com/$path.json?auth=${user.token}';
  }

  String databaseApi(String path) {
    return _databaseApi(path);
  }

  resetUser() {
    _user = UserModel();
  }

  Future<dynamic> post(String givenPath, Object data) async {
    try {
      String path = givenPath.contains(':uid')
          ? givenPath.replaceAll(':uid', user.uId!)
          : givenPath;
      final res = await http.post(Uri.parse(_databaseApi(path)),
          body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw HttpException(resData['error']);
      }
      if (resData == null) {
        throw HttpException('null');
      }
      return resData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> put(String givenPath, Object data) async {
    try {
      String path = givenPath.contains(':uid')
          ? givenPath.replaceAll(':uid', user.uId!)
          : givenPath;
      final res = await http.put(Uri.parse(_databaseApi(path)),
          body: json.encode(data));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw HttpException(resData['error']);
      }
      if (resData == null) {
        throw HttpException('null');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> get(String givenPath, [String givenFilter = '']) async {
    try {
      String path = givenPath.replaceAll(':uid', user.uId!);

      String filter = givenFilter.replaceAll(':uid', user.uId!);

      final res = await http.get(Uri.parse(_databaseApi(path) + filter));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw HttpException(resData["error"]);
      }
      return resData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String givenPath) async {
    try {
      String path = givenPath.contains(':uid')
          ? givenPath.replaceAll(':uid', user.uId!)
          : givenPath;
      final res = await http.delete(Uri.parse(_databaseApi(path)));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw HttpException(resData['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getUserData() async {
    try {
      final res = await http.get(Uri.parse(_databaseApi('users/${user.uId}')));
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw HttpException(resData['error']);
      }
      if (resData == null) {
        throw HttpException('null');
      }
      final token = _user.token;
      _user = UserModel.fromJson(Map<String, dynamic>.from(resData));
      _user.token = token;
    } catch (e) {
      rethrow;
    }
  }
}
