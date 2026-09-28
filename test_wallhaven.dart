import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
  
  final List<dynamic> data = response.data['data'];
  print('Data length: ${data.length}');
  print('First item: ${data[0]}');
}
