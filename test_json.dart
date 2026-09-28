import 'dart:convert';
void main() {
  var x = jsonDecode('{"a": 1}');
  print(x.runtimeType);
  print(x is Map<String, dynamic>);
}
