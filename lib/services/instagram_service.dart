import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/search_response.dart';

class InstagramService {
  static Future<SearchResponse> searchPopular(String keyword) async {
    // Load embedded sample data
    final jsonString = await rootBundle.loadString('assets/search_data.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return SearchResponse.fromJson(jsonData);
  }
}
