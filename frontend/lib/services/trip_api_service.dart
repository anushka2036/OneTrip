import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class TripApiService {
  // For Flutter Web running in Chrome on the same PC as FastAPI.
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Temporary development identity.
  // This must match the X-User-ID used when testing in FastAPI.
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-User-ID': 'test-user-001',
  };

  // ============================================================
  // CREATE TRIP
  // ============================================================

  static Future<Map<String, dynamic>> createTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    required int travelers,
  }) async {
    final uri = Uri.parse('$baseUrl/api/trips');

    final body = {
      'title': title,
      'destination': destination,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'budget': budget,
      'travelers': travelers,
    };

    try {
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      dynamic decoded;

      try {
        decoded = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
      } on FormatException {
        throw Exception(
          'FastAPI returned an invalid response '
          '(${response.statusCode}).',
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Unexpected response from FastAPI.');
      }

      final detail = decoded is Map
          ? decoded['detail']?.toString() ?? response.body
          : response.body;

      throw Exception('FastAPI error ${response.statusCode}: $detail');
    } on TimeoutException {
      throw Exception(
        'The request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception(
        'Could not connect to FastAPI. '
        'Check the server URL and CORS settings. $error',
      );
    }
  }

  // ============================================================
  // GET ALL TRIPS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getTrips() async {
    final uri = Uri.parse('$baseUrl/api/trips');

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }

        throw Exception('Unexpected response from FastAPI.');
      }

      throw Exception(
        'Could not load trips (${response.statusCode}): '
        '${response.body}',
      );
    } on TimeoutException {
      throw Exception('Request timed out. Check whether FastAPI is running.');
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  // ============================================================
  // UPDATE TRIP
  // PUT /api/trips/{trip_id}
  // ============================================================

  static Future<Map<String, dynamic>> updateTrip({
    required String tripId,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    required int travelers,
  }) async {
    final id = tripId.trim();

    if (id.isEmpty) {
      throw Exception('Trip ID is missing.');
    }

    final uri = Uri.parse('$baseUrl/api/trips/${Uri.encodeComponent(id)}');

    final body = {
      'title': title,
      'destination': destination,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'budget': budget,
      'travelers': travelers,
    };

    try {
      final response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      dynamic decoded;

      try {
        decoded = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
      } on FormatException {
        throw Exception(
          'FastAPI returned an invalid response '
          '(${response.statusCode}).',
        );
      }

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Unexpected response from FastAPI.');
      }

      final detail = decoded is Map
          ? decoded['detail']?.toString() ?? response.body
          : response.body;

      throw Exception(
        'Could not update trip (${response.statusCode}): $detail',
      );
    } on TimeoutException {
      throw Exception(
        'Update request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  // ============================================================
  // DELETE TRIP
  // ============================================================

  static Future<void> deleteTrip(String tripId) async {
    final id = tripId.trim();

    if (id.isEmpty) {
      throw Exception('Trip ID is missing.');
    }

    final uri = Uri.parse('$baseUrl/api/trips/${Uri.encodeComponent(id)}');

    try {
      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      dynamic decoded;

      try {
        decoded = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
      } on FormatException {
        decoded = <String, dynamic>{};
      }

      final detail = decoded is Map
          ? decoded['detail']?.toString() ?? response.body
          : response.body;

      throw Exception(
        'Could not delete trip (${response.statusCode}): $detail',
      );
    } on TimeoutException {
      throw Exception(
        'Delete request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  // ============================================================
  // DATE FORMATTER
  // ============================================================

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
