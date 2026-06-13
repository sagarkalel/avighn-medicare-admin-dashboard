import 'dart:convert';
import 'dart:developer';

import 'package:avighn_medicare/utils/app_constants.dart';
import 'package:http/http.dart' as http;

/// Central HTTP service for all Google Apps Script calls.
///
/// Apps Script POST requests always return a 301/302/307 redirect.
/// The [_post] method handles this automatically by following the redirect
/// with a GET request to the returned Location header — exactly the pattern
/// Apps Script requires.
class SheetsApiService {
  static final SheetsApiService _instance = SheetsApiService._internal();
  factory SheetsApiService() => _instance;
  SheetsApiService._internal();

  final String _baseUrl = AppConstants.appsScriptUrl;

  // Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // ─── GET ────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(Map<String, String> params) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

      final response = await http
          .get(uri) // no headers
          .timeout(const Duration(seconds: 30));
      log("GET Response=> ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      log("some exception on GET: $e");
      throw Exception(_handleError(e));
    }
  }

  // ─── POST (with redirect follow) ────────────────────────────────────────────

  Future<Map<String, dynamic>> post(Map<String, dynamic> body) async {
    try {
      // Step 1: Initial POST to the Apps Script URL
      final initial = await http
          .post(Uri.parse(_baseUrl), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      log("initial POST Response=> ${initial.body}");

      // Step 2: Apps Script always returns 301/302/307 — follow with GET
      if (initial.statusCode == 301 ||
          initial.statusCode == 302 ||
          initial.statusCode == 307) {
        final redirectUrl = initial.headers['location'];
        log("redirectUrl from POST=> $redirectUrl");

        log('[SheetsApiService] Redirect → $redirectUrl');
        if (redirectUrl != null) {
          final redirected = await http
              .get(Uri.parse(redirectUrl))
              .timeout(const Duration(seconds: 30));
          log("POST Response=> ${redirected.body}");
          return _handleResponse(redirected);
        }
      }

      // Fallback: no redirect (shouldn't happen with Apps Script, but safe)
      return _handleResponse(initial);
    } catch (e) {
      log("some exception on POST: $e");
      throw Exception(_handleError(e));
    }
  }

  // ─── Response / Error Handlers ───────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }
    throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
  }

  String _handleError(dynamic e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Unexpected error occurred';
  }
}
