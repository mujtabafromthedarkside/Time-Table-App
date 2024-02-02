import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getterAPI(String url) async {
  final apiUrl = Uri.parse(url);

  try {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      return jsonData;
    } else {
      throw Exception('Failed to load data from the API. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<Map<String, dynamic>> getterAPIWithDataPOST(String url, {Map<String, dynamic>? data}) async {
  final apiUrl = Uri.parse(url);

  try {
    final response = await http.post(
      apiUrl,
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      return jsonData;
    } else {
      throw Exception('Failed to load data from the API. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<Map<String, dynamic>> getterAPIWithDataGET(String url, {Map<String, dynamic>? data}) async {
  final apiUrl = Uri.parse(url);

  try {
    final response = await http.get(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Data': json.encode(data),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      return jsonData;
    } else {
      throw Exception('Failed to load data from the API. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
