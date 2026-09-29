// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

/// Standalone test script to test connectivity and response structure
/// from the live Wallhaven random search API.
void main() async {
  // Configure Dio with connection timeouts
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Perform search query
  final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
  
  // Extract and print results summary
  final List<dynamic> data = response.data['data'];
  print('Data length: ${data.length}');
  print('First item: ${data[0]}');
}
