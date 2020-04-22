import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_project_name/models/driver.dart';
import 'package:my_project_name/services/mto_services/mto_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  Driver _currentDriver;

  MTOAuthService _mtoAuthService = MTOAuthService();
  SharedPreferences _prefs;
  bool _isAuth = false;
  String badgeId;
  String badgeIdInput;
  String passwordInput;
  final String imagePrefix = "https://mytaxioffice.com/storage/";

  //*getters*//
  //is authenticated?
  bool get isAuth {
    return _isAuth;
  }

  //get current loged in driver data, return null if not authenticated
  Future<Driver> get currentDriver async {
    if (this._currentDriver == null) {
      await this.getDriver();
    }
    return this._currentDriver;
  }

  //*functions*//
  Future<bool> login() async {
    try {
      var response =
          await _mtoAuthService.login(this.badgeIdInput, this.passwordInput);
      if (!response.containsKey("error")) {
        _isAuth = true;
        //todo : add expiry date
        await saveToken(response['access_token']);
        await getDriver();
        notifyListeners();
        return true;
      } else {
        _isAuth = false;
        notifyListeners();
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    if (getToken() == null) {
      return false;
    }
    //todo : check expiry date
    if (await getDriver()) {
      _isAuth = true;
      notifyListeners();
      return true;
    } else {
      _isAuth = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getDriver() async {
    var token = await getToken();
    if (token != null) {
      var data = await _mtoAuthService.getDriver(mtoToken: token);
      if (!data.containsKey("error")) {
        _isAuth = true;
        this._currentDriver = createDriverObjectFromMap(data);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Driver createDriverObjectFromMap(data) {
    return new Driver(
      badgeId: data['PermitNumber'],
      id: data['id'].toString(),
      firstName: data['FirstName'],
      lastName: data['LastName'],
      pictureUrl: data['image'] == "" || data['image'] == null
          ? null
          : imagePrefix + data['image'],
      lisenceNumber: data['LicenseNumber'],
      licenseExpiry: data['LicenseExpiry'],
      permitExpiry: data['PermitExpiry'],
      abstractExpiry: data['AbstractExpiry'],
      homePhone: data['HomePhone'],
      taxiHost: data['Taxi_Host'],
      address: data['ADDRESS'],
      email: data['email'],
      startDate: data['START_DATE'],
      endDate: data['END_DATE'],
      status: data['DRIVER_STATUS'],
      licenseClass: data['LICENSE_CLASS'],
      licenseUrl: data['LICENSE_PATH'] == "" || data['LICENSE_PATH'] == null
          ? imagePrefix + data['LICENSE_PATH']
          : null,
      permitUrl: data['PERMIT_PATH'] == "" || data['PERMIT_PATH'] == null
          ? imagePrefix + data['PERMIT_PATH']
          : null,
      taxiHostUrl: data['TAXIHOST_PATH'] == "" || data['TAXIHOST_PATH'] == null
          ? imagePrefix + data['TAXIHOST_PATH']
          : null,
      abstractUrl: data['ABSTRACT_PATH'] == "" || data['ABSTRACT_PATH'] == null
          ? imagePrefix + data['ABSTRACT_PATH']
          : null,
      spFileUrl: data['SP_FILE_PATH'] == "" || data['SP_FILE_PATH'] == null
          ? imagePrefix + data['SP_FILE_PATH']
          : null,
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  Future<void> logout() async {
    var token = await getToken();
    if (token != null) {
      await _mtoAuthService.logout(mtoToken: token);
    }
    _prefs = await SharedPreferences.getInstance();
    _prefs.remove('mto_access_token');
    _isAuth = false;
    notifyListeners();
  }

  Future<String> getToken() async {
    _prefs = await SharedPreferences.getInstance();
    var token = _prefs.getString('mto_access_token');
    if (token == null) {
      _isAuth = false;
    }
    return token;
  }

  Future<void> saveToken(String token) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.remove('mto_access_token');
    _prefs.setString('mto_access_token', token);
    //todo
    //add expiry date
  }
}
