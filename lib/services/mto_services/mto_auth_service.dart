import 'package:flutter/material.dart';
import 'package:my_project_name/services/mto_services/mto_api_service.dart';
import 'package:logger/logger.dart';

class MTOAuthService {
  Future<dynamic> login(String permitNumber, String password) async {
    return await MTOApiService().httpPost('driver/auth/login',
        {'PermitNumber': permitNumber, 'password': password});
  }

  Future<dynamic> getDriver({@required mtoToken}) async {
    return await MTOApiService(token: mtoToken).httpGet('driver/auth/user');
  }

  Future<dynamic> logout({@required mtoToken}) async {
    return await MTOApiService(token: mtoToken).httpPost('auth/logout', {});
  }
}
