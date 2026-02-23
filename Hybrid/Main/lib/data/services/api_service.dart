import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/api_config.dart';
import '../../core/exceptions/api_exception.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers([Map<String, String>? extra]) {
    final headers = {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
  Future<dynamic> postMultipart(
      String endpoint, {
        required Map<String, String> fields,
        List<File>? files,
        Uint8List? webImageBytes,
        String? webImageName,
        String fileFieldName = 'images',
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('POST', uri);
    return _sendMultipartRequest(request, fields, files, webImageBytes, webImageName, fileFieldName);
  }

  Future<dynamic> putMultipart(
      String endpoint, {
        required Map<String, String> fields,
        List<File>? files,
        Uint8List? webImageBytes,
        String? webImageName,
        String fileFieldName = 'images',
      }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final request = http.MultipartRequest('PUT', uri);
    return _sendMultipartRequest(request, fields, files, webImageBytes, webImageName, fileFieldName);
  }

  Future<dynamic> _sendMultipartRequest(
      http.MultipartRequest request,
      Map<String, String> fields,
      List<File>? files,
      Uint8List? webImageBytes,
      String? webImageName,
      String fileFieldName,
      ) async {
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }

    fields.forEach((key, value) => request.fields[key] = value);

    if (kIsWeb) {
      if (webImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            webImageBytes,
            filename: webImageName ?? 'upload.jpg',
          ),
        );
      }
    } else {
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          request.files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }
}
