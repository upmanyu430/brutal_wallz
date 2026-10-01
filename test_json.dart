// ignore_for_file: avoid_print

import 'dart:convert';

/// Standalone test script to verify Dart's [jsonDecode] return types and Map casting.
void main() {
  // Decode a sample JSON string object
  var x = jsonDecode('{"a": 1}');

  // Print decoded runtime type
  print(x.runtimeType);

  // Check type conformance to Map<String, dynamic>
  print(x is Map<String, dynamic>);
}
