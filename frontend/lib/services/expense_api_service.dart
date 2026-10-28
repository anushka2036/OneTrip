import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ExpenseApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-User-ID': 'test-user-001',
  };

  static Future<Map<String, dynamic>> createExpense({
    required String tripId,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final uri = Uri.parse('$baseUrl/api/expenses');

    final body = {
      'trip_id': tripId,
      'category': category,
      'description': description,
      'amount': amount,
      'date': _formatDate(date),
      'note': note,
    };

    try {
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      return _handleMapResponse(response, successCodes: {200, 201});
    } on TimeoutException {
      throw Exception(
        'The request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  static Future<List<Map<String, dynamic>>> getExpenses(String tripId) async {
    final uri = Uri.parse(
      '$baseUrl/api/expenses/trip/${Uri.encodeComponent(tripId)}',
    );

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Could not load expenses '
          '(${response.statusCode}): ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Unexpected response from FastAPI.');
      }

      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } on TimeoutException {
      throw Exception('Request timed out. Check whether FastAPI is running.');
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  static Future<Map<String, dynamic>> getExpense(String expenseId) async {
    final uri = Uri.parse(
      '$baseUrl/api/expenses/${Uri.encodeComponent(expenseId)}',
    );

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      return _handleMapResponse(response, successCodes: {200});
    } on TimeoutException {
      throw Exception('Request timed out. Check whether FastAPI is running.');
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  static Future<Map<String, dynamic>> updateExpense({
    required String expenseId,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/expenses/${Uri.encodeComponent(expenseId)}',
    );

    final body = {
      'category': category,
      'description': description,
      'amount': amount,
      'date': _formatDate(date),
      'note': note,
    };

    try {
      final response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      return _handleMapResponse(response, successCodes: {200});
    } on TimeoutException {
      throw Exception(
        'Update request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  static Future<void> deleteExpense(String expenseId) async {
    final uri = Uri.parse(
      '$baseUrl/api/expenses/${Uri.encodeComponent(expenseId)}',
    );

    try {
      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      dynamic decoded;

      try {
        decoded = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } on FormatException {
        decoded = {};
      }

      final detail = decoded is Map
          ? decoded['detail']?.toString() ?? response.body
          : response.body;

      throw Exception(
        'Could not delete expense '
        '(${response.statusCode}): $detail',
      );
    } on TimeoutException {
      throw Exception(
        'Delete request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  static Future<Map<String, dynamic>> getExpenseSummary(String tripId) async {
    final uri = Uri.parse(
      '$baseUrl/api/expenses/trip/'
      '${Uri.encodeComponent(tripId)}/summary',
    );

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      return _handleMapResponse(response, successCodes: {200});
    } on TimeoutException {
      throw Exception(
        'Summary request timed out. Check whether FastAPI is running.',
      );
    } on http.ClientException catch (error) {
      throw Exception('Could not connect to FastAPI: $error');
    }
  }

  static Map<String, dynamic> _handleMapResponse(
    http.Response response, {
    required Set<int> successCodes,
  }) {
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

    if (successCodes.contains(response.statusCode)) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Unexpected response from FastAPI.');
    }

    final detail = decoded is Map
        ? decoded['detail']?.toString() ?? response.body
        : response.body;

    throw Exception('FastAPI error ${response.statusCode}: $detail');
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
