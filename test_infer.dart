// ignore_for_file: avoid_print

/// Standalone test script to verify Dart's type inference on mapped lists.
void main() {
  // Dynamic list representing parsed JSON collection
  List<dynamic> data = [1, 2, 3];

  // Map elements to string and materialize into a list
  var x = data.map((e) => e.toString()).toList();

  // Print inferred runtime type of the resulting list
  print(x.runtimeType);
}
