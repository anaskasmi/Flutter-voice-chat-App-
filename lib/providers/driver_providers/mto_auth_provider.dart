import 'package:flutter/foundation.dart';
import 'package:my_project_name/models/driver.dart';
import 'package:my_project_name/services/mto_services/mto_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class DriverMTOAuthProvider with ChangeNotifier {
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
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    if (await getToken() == null) {
      Logger().i('No Token Found');
      return false;
    }
    //todo : check expiry date
    if (await getDriver()) {
      _isAuth = true;
      return true;
    } else {
      _isAuth = false;
      return false;
    }
  }

  Future<bool> isAllowedToUseChat() async {
    Logger().wtf(" is allowed function called !!!");
    var token = await getToken();
    var data = await _mtoAuthService.getDriver(mtoToken: token);
    if (!data.containsKey("error")) {
      this._currentDriver = createDriverObjectFromMap(data);
      Logger().i("is allowed value : "+_currentDriver.isAllowedToUseChat.toString());
      if (_currentDriver.isAllowedToUseChat == true) {

        return true;
      }
      else{
        return false;
      }

    }
    Logger().e("error fetching is allowed ");
    return false;

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
        Logger().w("not logged in");
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
      isAllowedToUseChat:
      data['is_able_to_use_app'] == "1"
          ? true
          : false,
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
