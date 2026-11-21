import 'dart:convert';

import 'package:http/http.dart' as http;

import 'env.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final TokenStorage _tokenStorage;
  final http.Client _http = http.Client();

  /// Called when the backend reports the session token is invalid/expired, so the app can drop
  /// back to the sign-in screen instead of showing a raw "401" error on every subsequent call.
  void Function()? onUnauthorized;

  ApiClient(this._tokenStorage);

  Future<Map<String, String>> _headers({bool authorized = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (authorized) {
      final token = await _tokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final stringQuery = query?.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse('$apiBaseUrl$path').replace(queryParameters: stringQuery);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }
    String message = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) message = body['message'];
    } catch (_) {
      // keep default message
    }
    throw ApiException(response.statusCode, message);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool authorized = true}) async {
    final response = await _http.get(_uri(path, query), headers: await _headers(authorized: authorized));
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body, bool authorized = true}) async {
    final response = await _http.post(
      _uri(path),
      headers: await _headers(authorized: authorized),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> put(String path, {Object? body, bool authorized = true}) async {
    final response = await _http.put(
      _uri(path),
      headers: await _headers(authorized: authorized),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }
}
