import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_project_name/utilities/appExceptions.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  String token;
  String baseUrl = "mytaxioffice.com";
  String path = "api";
  //constructor
  ApiService({@required this.token}) {
    assert(this.token != null);
  }
//checking if response is valide
  dynamic _returnResponse(http.Response response) {
    Logger().i("evaluating response ...  ");
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        Logger().i("response 200 OK ...  ");

        return responseJson;
      case 400:
        Logger().e("response 400 ERROR BAD REQUEST ...  ");

        throw BadRequestException(response.body.toString());

      case 403:
        Logger().e("response 403 ERROR  Unauthorised ...  ");

        throw UnauthorisedException(response.body.toString());
      default:
        Logger().e("response ${response.statusCode} Uknown Error ...  ");

        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  //http get methode
  Future<dynamic> httpGet(String endPoint, {Map<String, String> query}) async {
    Logger().e("Http GET initialized ");

    Uri uri;
    var responseJson;

    if (query != null) {
      uri = Uri.https(baseUrl, '$this.path/$endPoint', query);
    } else {
      uri = Uri.https(baseUrl, '$this.path/$endPoint');
    }

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $this.token',
        'Accept': 'application/json'
      });
      responseJson = _returnResponse(response);
      return responseJson;
    } on Exception {
      throw FetchDataException('An Error Has accured');
    } catch (e) {
      Logger().e("catch : http get error accured ");
    }
  }

  Future<http.Response> httpPost(String endPoint, Object body) async {
    Logger().e("Http POST initialized ");

    Uri uri = Uri.https(baseUrl, '$this.path/$endPoint');
    var responseJson;
    try {
      final response = await http.post(uri, body: body, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      });
      responseJson = _returnResponse(response);
      return responseJson;
    } catch (e) {
      Logger().e("catch : http POST error accured ");
    }
  }

  Future<http.StreamedResponse> httpPostWithFile(String endPoint,
      String filePath, String fieldName, String duration) async {
    Logger().e("Http POST WITH FILE initialized ");
    Uri uri = Uri.https(baseUrl, '$this.path/$endPoint');
    var request = http.MultipartRequest('POST', uri);
    request.fields['duration'] = duration;
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    request.headers.addAll(
        {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    try {
      request.send().then((response) {
        print('finish sending : ' + response.toString());
        // response.stream.transform(utf8.decoder).listen((value) {
        //   print(value);
        // });
        Logger().i("Evaluaing http Post With File ...  ");
        switch (response.statusCode) {
          case 200:
            Logger().i("response 200 OK ...  ");
            return response;
          case 400:
            Logger().e("response 400 ERROR BAD REQUEST ...  ");
            throw BadRequestException(response.reasonPhrase);

          case 403:
            Logger().e("response 403 ERROR  Unauthorised ...  ");

            throw UnauthorisedException(response.reasonPhrase);
          default:
            Logger().e("response ${response.statusCode} Uknown Error ...  ");

            throw FetchDataException(
                'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
        }
      });
    } catch (e) {
      Logger().e("catch : http Post With File Error ");
    }
  }
}
