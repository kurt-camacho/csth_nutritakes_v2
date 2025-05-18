import 'package:tflite_flutter/tflite_flutter.dart';

Future<void> testModelLoading() async {
  try {
    final interpreter = await Interpreter.fromAsset(
      'assets/models/food_model.tflite',
    );
    print('✅ Model loaded successfully!');
    print('Input Details: ${interpreter.getInputTensors()}');
    print('Output Details: ${interpreter.getOutputTensors()}');
    interpreter.close();
  } catch (e) {
    print('❌ Loading failed: $e');
    throw Exception('Model test failed'); // For test runner
  }
}
