import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

Future<void> testInference() async {
  // 1. Load model and labels
  final interpreter = await Interpreter.fromAsset('assets/model.tflite');
  final labels = await rootBundle
      .loadString('assets/labels.txt')
      .then((s) => s.split('\n'));

  // 2. Create dummy input (adjust shape to your model!)
  final inputShape = interpreter.getInputTensors()[0].shape;
  final input = List.filled(
    inputShape.reduce((a, b) => a * b),
    0.5, // Neutral value
  ).reshape(inputShape);

  // 3. Run inference
  final output = List.filled(labels.length, 0.0).reshape([1, labels.length]);
  interpreter.run(input, output);

  // 4. Verify output
  final predictions = output[0];
  print('🎯 Predictions:');
  predictions.asMap().forEach(
    (i, conf) => print('${labels[i]}: ${conf.toStringAsFixed(4)}'),
  );

  interpreter.close();
}
