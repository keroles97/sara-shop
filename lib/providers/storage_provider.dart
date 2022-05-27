import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception_model.dart';

class StorageProvider with ChangeNotifier {
  String? _token;

  Future<void> _auth() async {
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "3dc4c3acba685b3aa64c686ea396193b4e8f60ef",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQChb0RQbq7VH79n\n5vtH/JswKq17Iwvatynol6kf6zB6DODLDEvdXOepYySVuV/yMAkpSNekd1CNUKmy\nxVfjJX09Y9ZTpdU+VldSzP392Lhi2+ZIyIf7+Goe7ZSRtT/MmRUrwSb9zOS00OIV\nr/QsYhe0I+CjlHff1rDM+NIXmMzzsMDueeDNcr4C+M3PV9GhId7tIDDjboh2/7HW\n4a2GwHM4WsIJ2z0WoeIFwPVlbvVZ5tQMLoDzZc71pFq91PZSF7ZDuXjemKSB3gfK\nlzHtyLUHAuXWbXkFYfEAelV0+LB9jx5P98P++O+41kSxj5jFOHg/iAYt9YJ0BPYd\nUBtviYFVAgMBAAECggEAI7BeCWwWwa4lmhpR9h2tz024EY9zaPRyUuXocVKE4o6j\nSbBbu0H1QxjUdzdGs1uUQujEJ6trBvrMsWV4YxKgJ+jA8rgoNwJOhtMj2bFGPjDA\nLdoLWhSWnWTHohjQVHKJYCVw8c4Qx7qgKMw/7mn3NI9z86X4hGdJqd7eT3Ir6TmR\nSKebeWAiQsb/8mueBoHpe6acF1uAhC9qs0PlGJtA0RFPPHrzGARMYnGCnDjIDYxm\n3MSWiFEaSwqEAIi634d2rvgbnlhDVigd8pB4f8aI0jYNvrosnsxauLd0hFcBhsc+\nCu+QGWYG5L/ZGydmp63nj2RR2BNM3evkE+VgwKXV1wKBgQDkN2cmwqyNtZIks+eX\nHbe1NHWSWriG5+h4qM/ztqD4Bn+Sm2uFBEpfAVCItpNcehaVgMMwt2G/I9SJTIyv\nUnOWb01KKF73HodMcjFo5BKmllEYo0Ok44UDaSnkm6dl+rLnafV5E3e7Qvc6B1xr\nqh7Ym50YUAB0umX8q583GBK3LwKBgQC1Foqr9cW+mkrvBEgjXU/spY49AC30oXD8\nHvFXNcbGQbHDah8wvnNQ5Pjh+c/5jeHabZFnIqh/hYmMCX1LnVCiOIEpv2OM0PoX\nJrRXZOs9K74k7mV2/5yaYrgBLupe02H9sz5XPG1mxMBF+K+xvzyoSLzsW7BJQeqi\nRKKl4XDuuwKBgQCpOTvPzgLNgZnAhXZw46RZRXD4+TRjNIt5DRRGD2IFCCyItZ5g\nn/HVyM/C0D8tD4q3iSczdIeSiCsNNCoNxwHWxul018KzU3vX/8ULljMOO+AeeNGr\n7tmu0cgysAjM4bzPRA61nO3neZyA9vxdCWSeEaXHZWsxIxaE6W3CGKOoGQKBgQCC\nqdk1awlcFoirHjPPEK1y26JecZq3QSX9RXZurubWduCFWDVZPpKGdDEBHPfr4Wxt\n51FbUa6zFO/Ck7ZMsR5VbuAD940lNkS+H7dQuAjlAoMYssuTqayd2U1bzTZfZbb3\nEDaTS47E8IKr+l0LrClgY9ut0BrLQTzECTIy7xBFsQKBgC/0c4y63hwTT0wPbbTA\nYIgEnDZuHMx1LDP3zPZYWPV9nMv8PPiwtqJ1FJs4MyD0QgsBN+Q8DsFWi/NYw+/+\nTTih5TyX8j94Tv8Z/BhKVHQhTcxKqdDkOL1C6i7ESTRgdxq+YJsKiuKh3miAtP95\nNsfP7JxoXiFnc85SrViO6tm+\n-----END PRIVATE KEY-----\n",
      "client_email": "sara-shop-ccd7d@appspot.gserviceaccount.com",
      "client_id": "114260890382178327333.apps.googleusercontent.com",
      "type": "service_account"
    });

    const scopes = [
      'https://www.googleapis.com/auth/cloud-platform',
    ];

    final client = http.Client();
    AccessCredentials credentials =
        await obtainAccessCredentialsViaServiceAccount(
            accountCredentials, scopes, client);
    client.close();
    _token = credentials.accessToken.data;
  }

  Future<String> post(String givenPath, file) async {
    try {
      if (_token == null) await _auth();
      String path = givenPath.replaceAll('/', '%2f');
      final res = await http.post(
        Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/sara-shop-ccd7d.appspot.com/o/$path?uploadType=media'),
        body: file,
        headers: {
          "Content-Type": "image/png",
          "Authorization": "Bearer " + _token!,
        },
      );
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw HttpException(resData['error']['message']);
      }
      String downloadUrl =
          'https://firebasestorage.googleapis.com/v0/b/sara-shop-ccd7d.appspot.com/o/${resData['name'].toString().replaceAll('/', '%2f')}?alt=media&token=${resData['downloadTokens'].toString()}';
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String givenPath) async {
    try {
      if (_token == null) await _auth();
      String path = givenPath.replaceAll('/', '%2f');
      final res = await http.delete(
        Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/sara-shop-ccd7d.appspot.com/o/$path'),
        headers: {
          "Authorization": "Bearer " + _token!,
        },
      );

      if (res.statusCode >= 400) {
        final resData = json.decode(res.body);
        throw HttpException(resData['error']['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
