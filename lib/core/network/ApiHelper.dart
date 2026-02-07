import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiResult {
  bool? isDone;
  String? requestedMethod;
  dynamic data;
  String? message;
  int? statusCode;

  ApiResult({
    this.isDone,
    this.requestedMethod,
    this.data,
    this.message,
    this.statusCode,
  });
}

class ApiHelper {
  // static String baseUrl = 'https://app.parsiweb.net/';
  static String baseUrl = 'https://app.parsiweb.net/';
  // static String baseUrl = 'http://192.168.1.1:3000/';

  /// -----------------------------
  /// 🔁 متد مشترک برای ریترای کردن
  /// -----------------------------
  static Future<http.Response?> _retryRequest(
      Future<http.Response> Function() requestFunction, {
        int retries = 3,
        int delayMs = 500,
      }) async {
    http.Response? response;

    for (int i = 0; i < retries; i++) {
      try {
        response = await requestFunction().timeout(const Duration(seconds: 5));

        if (response.statusCode != 0) {
          // اگر پاسخی اومد، برگرد
          return response;
        }
      } catch (e) {
        debugPrint("Retry ${i + 1} failed: $e");
      }

      await Future.delayed(Duration(milliseconds: delayMs));
    }

    return null; // بعد از همه retry ها هیچ پاسخی نیومد
  }

  /// -----------------------------
  /// POST Request + Retry
  /// -----------------------------
  static Future<ApiResult> makePostRequest({
    String? path,
    Map<String, String> header = const {},
    Map body = const {},
    Map<String, dynamic> queryParameters = const {},
  }) async {
    ApiResult result = ApiResult(requestedMethod: "POST");

    final uri =
    Uri.parse(baseUrl + path!).replace(queryParameters: queryParameters);
    final response = await _retryRequest(
          () => http.post(uri, headers: header, body: jsonEncode(body)),
      retries: 3,
    );

    if (response == null) {
      result.isDone = false;
      result.message = "خطا در اتصال به سرور. لطفاً دوباره تلاش کنید.";
      return result;
    }

    try {
      dynamic data = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : null;

      result.data = data;
      result.statusCode = response.statusCode;
      result.isDone = true;
      return result;
    } catch (e) {
      result.isDone = false;
      result.message = "پاسخ نامعتبر از سرور";
      return result;
    }
  }

  /// -----------------------------
  /// PUT Request + Retry
  /// -----------------------------
  static Future<ApiResult> makePutRequest({
    String? path,
    Map<String, String> header = const {},
    Map body = const {},
    Map<String, dynamic> queryParameters = const {},
  }) async {
    ApiResult result = ApiResult(requestedMethod: "PUT");

    final uri = Uri.parse(baseUrl + path!);

    final response = await _retryRequest(
          () => http.put(uri, headers: header, body: jsonEncode(body)),
    );

    if (response == null) {
      result.isDone = false;
      result.message = "خطا در اتصال به سرور.";
      return result;
    }

    try {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      result.data = data;
      result.statusCode = response.statusCode;
      result.isDone = true;
      return result;
    } catch (e) {
      result.isDone = false;
      result.message = "پاسخ نامعتبر از سرور";
      return result;
    }
  }

  /// -----------------------------
  /// DELETE Request + Retry
  /// -----------------------------
  static Future<ApiResult> makeDeleteRequest({
    String? path,
    Map<String, String> header = const {},
    Map body = const {},
    Map<String, dynamic> queryParameters = const {},
  }) async {
    ApiResult result = ApiResult(requestedMethod: "DELETE");

    final uri = Uri.parse(baseUrl + path!);

    final response = await _retryRequest(
          () => http.delete(uri, headers: header, body: jsonEncode(body)),
    );

    if (response == null) {
      result.isDone = false;
      result.message = "خطا در اتصال به سرور.";
      return result;
    }

    try {
      dynamic data = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.bodyBytes))
          : null;

      result.data = data;
      result.statusCode = response.statusCode;
      result.isDone = true;
      return result;
    } catch (e) {
      result.isDone = false;
      result.message = "پاسخ نامعتبر از سرور";
      return result;
    }
  }

  /// -----------------------------
  /// GET Request + Retry
  /// -----------------------------
  static Future<ApiResult> makeGetRequest({
    String? path,
    Map<String, String> header = const {},
    Map<String, dynamic> queryParameters = const {},
  }) async {
    ApiResult result = ApiResult(requestedMethod: "GET");

    final uri =
    Uri.parse(baseUrl + path!).replace(queryParameters: queryParameters);

    print(uri);
    final response = await _retryRequest(
          () => http.get(uri, headers: header),
    );
    print(response?.body);
    if (response == null) {
      result.isDone = false;
      result.message = "خطا در اتصال به سرور.";
      return result;
    }

    try {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      result.data = data;
      result.statusCode = response.statusCode;
      result.isDone = true;
      return result;
    } catch (e) {
      result.isDone = false;
      result.message = "پاسخ نامعتبر از سرور";
      return result;
    }
  }
}
