import 'dart:async';
import 'dart:convert';

import 'package:app/models/http_exception_model.dart';
import 'package:app/providers/language_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/info_alert_dialog.dart';

class AuthProvider with ChangeNotifier {
  bool loaded = false;
  String? _token;
  String? _refreshToken;
  String? _uId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get uId => _uId;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String _authApi(String urlSegment) {
    return 'https://identitytoolkit.googleapis.com/v1/accounts'
        ':$urlSegment?key=AIzaSyCtWaNbsGZp9L3JZJLuByxUmdEmRoBC1NQ';
  }

  String _refreshTokenApi() {
    return 'https://securetoken.googleapis.com/v1/token?key=AIzaSyCtWaNbsGZp9L3JZJLuByxUmdEmRoBC1NQ';
  }

  Future<List<String>> register(String email, String password) async {
    try {
      final res = await http.post(Uri.parse(_authApi('signUp')),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        if (kDebugMode) {
          print('register_http_error' + resData['error'].toString());
        }
        throw HttpException(resData['error']['message']);
      }
      return [resData['localId'], resData['idToken']];
    } catch (e) {
      if (kDebugMode) {
        print('register_error' + e.toString());
      }
      rethrow;
    }
  }

  Future<void> login(BuildContext context, LanguageProvider lang, String email,
      String password) async {
    try {
      final res = await http.post(Uri.parse(_authApi('signInWithPassword')),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        if (kDebugMode) {
          print('login_http_error' + resData['error'].toString());
        }
        throw HttpException(resData['error']['message']);
      }
      if (await checkEmailVerification(resData['idToken'])) {
        _token = resData['idToken'];
        _refreshToken = resData['refreshToken'];
        _uId = resData['localId'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(resData['expiresIn'])));
        final prefs = await SharedPreferences.getInstance();
        String userData = json.encode({
          'token': _token,
          'refreshToken': _refreshToken,
          'uId': _uId,
          'expiryDate': _expiryDate!.toIso8601String(),
        });
        prefs.setString('userData', userData);
        _autoSignOut();
        notifyListeners();
      } else {
        await sendEmailVerification(resData['idToken']);
        showInfoAlertDialog(context, lang, 'email_verification_sent', false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('login_error' + e.toString());
      }
      rethrow;
    }
  }

  Future<bool> checkEmailVerification(String token) async {
    try {
      final res = await http.post(Uri.parse(_authApi('lookup')),
          body: json.encode({
            'idToken': token,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        if (kDebugMode) {
          print('checkEmailVerification_http_error' +
              resData['error'].toString());
        }
        throw HttpException(resData['error']['message']);
      }
      return resData['users'][0]['emailVerified'];
    } catch (e) {
      if (kDebugMode) {
        print('checkEmailVerification_error' + e.toString());
      }
      rethrow;
    }
  }

  Future<void> sendEmailVerification(String token) async {
    try {
      final res = await http.post(Uri.parse(_authApi('sendOobCode')),
          body: json.encode({
            'requestType': 'VERIFY_EMAIL',
            'idToken': token,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        if (kDebugMode) {
          print(
              'sendEmailVerification_http_error' + resData['error'].toString());
        }
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('sendEmailVerification_error' + e.toString());
      }
      rethrow;
    }
  }

  Future<void> sendResetPasswordEmail(String email) async {
    try {
      final res = await http.post(Uri.parse(_authApi('sendOobCode')),
          body: json.encode({
            'requestType': 'PASSWORD_RESET',
            'email': email,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        if (kDebugMode) {
          print('sendResetPasswordEmail_http_error' +
              resData['error'].toString());
        }
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('sendResetPasswordEmail_error' + e.toString());
      }
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    try {
      final res = await http.post(Uri.parse(_refreshTokenApi()),
          body: json.encode({
            'grant_type': 'refresh_token',
            'refresh_token': _refreshToken,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        if (kDebugMode) {
          print('refreshToken_http_error' + resData['error'].toString());
        }
      } else {
        _token = resData['id_token'];
        _refreshToken = resData['refresh_token'];
        _uId = resData['user_id'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(resData['expires_in'])));
        final prefs = await SharedPreferences.getInstance();
        String userData = json.encode({
          'token': _token,
          'refreshToken': _refreshToken,
          'uId': _uId,
          'expiryDate': _expiryDate!.toIso8601String(),
        });
        prefs.setString('userData', userData);
        _autoSignOut();
      }
    } catch (e) {
      if (kDebugMode) {
        print('refreshToken_error' + e.toString());
      }
      rethrow;
    }
  }

  Future<void> tryAutoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("userData")) {
      final Map<String, dynamic> userData =
          json.decode(prefs.getString("userData")!) as Map<String, dynamic>;
      final expiryDate = DateTime.parse(userData['expiryDate']);
      if (expiryDate.isBefore(DateTime.now())) {
        _refreshToken = userData['refreshToken'].toString();
        prefs.remove('userData');
        await refreshToken();
      } else {
        _token = userData['token'].toString();
        _refreshToken = userData['refreshToken'].toString();
        _uId = userData['uId'].toString();
        _expiryDate = expiryDate;
        _autoSignOut();
      }
    }
    loaded = true;
    notifyListeners();
  }

  void _autoSignOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _uId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    try {
      final res = await http.post(Uri.parse(_authApi('update')),
          body: json.encode({
            'idToken': token,
            'email': email,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      await logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      final res = await http.post(Uri.parse(_authApi('update')),
          body: json.encode({
            'idToken': token,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      await logout();
    } catch (e) {
      rethrow;
    }
  }

  String handleAuthenticationError(HttpException error) {
    String message = error.toString();
    if (message.contains('EMAIL_EXISTS')) {
      return 'already_signed_up';
    } else if (message.contains('INVALID_EMAIL')) {
      return 'invalid_email';
    } else if (message.contains('INVALID_PASSWORD')) {
      return 'wrong_password';
    } else if (message.contains('EMAIL_NOT_FOUND')) {
      return 'email_not_found';
    } else if (message.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return 'too_many_attempts';
    } else if (message.contains('INVALID_ID_TOKEN')) {
      return 'requires-recent-login';
    } else if (message.contains('CREDENTIAL_TOO_OLD_LOGIN_AGAIN')) {
      return 'requires-recent-login';
    } else {
      return 'unknown_error';
    }
  }
}
