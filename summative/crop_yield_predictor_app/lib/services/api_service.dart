import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_input.dart';

class ApiService {
  static const String baseUrl = 'https://linear-regression-model-gjes.onrender.com';
  
  static Future<Map<String, dynamic>> predictYield(PredictionInput input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(input.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to predict yield: ${response.body}');
    }
  }
}