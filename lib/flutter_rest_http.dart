library flutter_rest_http;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef GlobalHeadersCallback = Future<Map<String, String>> Function();

String _baseURL = "https://example.com";
String _defaultError = "Cannot complete your request. Please try again";
String _connectionError = "Please check your internet connection";
String _timeoutError = "Your request timed out. Please try again";

GlobalHeadersCallback? _globalHeaders;

Uri getUrl(String path, {bool withBase = true}) {
  var link = withBase ? "$_baseURL$path" : path;
  if (kDebugMode) {
    print(link);
  }
  return Uri.parse(link);
}

class RestHttp {
  static void init({String? baseURL, GlobalHeadersCallback? globalHeaders}) {
    if (baseURL != null) {
      _baseURL = baseURL;
    }
    _globalHeaders = globalHeaders;
  }

  static Future<ApiRawResponse> _processRawResponse(
      Future<http.Response> request) async {
    try {
      var response = await request.timeout(const Duration(seconds: 30));
      if (kDebugMode) {
        print(response.body);
      }
      return ApiRawResponse(response.statusCode, response.body);
    } on TimeoutException {
      throw ApiException(title: "Network Error", message: _timeoutError);
    } on SocketException {
      throw ApiException(title: "Network Error", message: _connectionError);
    } catch (err, stack) {
      if (kDebugMode) {
        print(stack);
      }
      if (err is ApiException) {
        throw ApiException(title: err.title, message: err.message);
      }
      throw ApiException(title: "Request Error", message: _defaultError);
    }
  }

  static Future<ApiResponse> _processResponse(
      Future<http.Response> request) async {
    try {
      var response = await request.timeout(const Duration(seconds: 5));
      if (kDebugMode) {
        print(response.statusCode);
        print(response.body);
      }

      return ApiResponse(
          response.statusCode,
          response.statusCode.mayHaveBody()
              ? json.decode(response.body)
              : null);
    } on TimeoutException {
      throw ApiException(title: "Network Error", message: _timeoutError);
    } on SocketException {
      throw ApiException(title: "Network Error", message: _connectionError);
    } catch (err, stack) {
      if (kDebugMode) {
        print(err);
        print(stack);
      }

      if (err is ApiException) {
        throw ApiException(title: err.title, message: err.message);
      }
      throw ApiException(title: "Request Error", message: _defaultError);
    }
  }

  static Future<Map<String, String>> _getHeaders(
      Map<String, String>? headers) async {
    headers ??= <String, String>{};
    headers.addAll({
      "Accept": "application/json",
      "Content-Type": "application/json; charset=UTF-8"
    });

    if (_globalHeaders != null) {
      headers.addAll(await _globalHeaders!());
    }

    if (kDebugMode) {
      print("Headers: $headers");
    }
    return headers;
  }

  static Future<ApiResponse> get(String path,
      {Map<String, String>? headers}) async {
    return _processResponse(
        http.get(getUrl(path), headers: await _getHeaders(headers)));
  }

  static Future<ApiRawResponse> getRaw(String path,
      {Map<String, String>? headers}) async {
    return _processRawResponse(http.get(getUrl(path, withBase: false),
        headers: await _getHeaders(headers)));
  }

  static Future<ApiResponse> post(String path,
      {Map<String, dynamic>? params, Map<String, String>? headers}) async {
    var json = jsonEncode(params);

    if (kDebugMode) {
      print("JSON");
      print(json);
    }

    return _processResponse(http.post(getUrl(path),
        body: jsonEncode(params), headers: await _getHeaders(headers)));
  }

  static Future<ApiResponse> patch(String path,
      {Map<String, String?>? params, Map<String, String>? headers}) async {
    return _processResponse(http.patch(getUrl(path),
        body: params, headers: await _getHeaders(headers)));
  }

  static List<ValidationError> getValidationErrors(dynamic response) {
    try {
      return response.body["errors"].keys.map<ValidationError>((k) {
        return ValidationError(
            key: k, errors: List<String>.from(response.body["errors"][k]));
      }).toList();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      return [];
    }
  }
}

class ApiResponse {
  int code;
  dynamic body;

  ApiResponse(this.code, this.body);
}

class ApiRawResponse {
  int code;
  String body;

  ApiRawResponse(this.code, this.body);
}

class ApiException implements Exception {
  final String? title;
  final String? message;

  ApiException({this.title, this.message});
}

class ValidationError {
  String? key;
  List<String>? errors;

  ValidationError({this.key, this.errors});
}

extension HttpStatusCodes on int {
  bool httpSuccess() {
    return this >= 200 && this < 300;
  }

  bool mayHaveBody() {
    return httpSuccess() ||
        httpBadRequest() ||
        httpUnauthenticated() ||
        this == 412;
  }

  bool httpBadRequest() {
    return this == 400;
  }

  bool httpUnauthenticated() {
    return this == 401;
  }
}
