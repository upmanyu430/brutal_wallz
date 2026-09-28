void main() {
  List<dynamic> data = [1, 2, 3];
  var x = data.map((e) => e.toString()).toList();
  print(x.runtimeType);
}
