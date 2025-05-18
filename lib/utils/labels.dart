import 'package:flutter/services.dart' show rootBundle;

class Labels {
  static List<String> labels = [];

  static Future<void> loadLabels() async {
    final labelData = await rootBundle.loadString('assets/labels.txt');
    labels = labelData.split('\n');
  }
}
