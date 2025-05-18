import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  static const int inputSize = 224;
  static const double mean = 127.5;
  static const double std = 127.5;

  Future<void> initialize() async {
    await _loadModel();
    await _loadLabels();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('Error loading model: $e');
      throw Exception('Failed to load model');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((l) => l.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Error loading labels: $e');
      throw Exception('Failed to load labels');
    }
  }

  Future<String> classifyImage(Uint8List imageBytes) async {
    if (!_isModelLoaded || _labels.isEmpty) {
      throw Exception('Model or labels not loaded');
    }

    try {
      final input = _preprocessImage(imageBytes);
      final output = _runInference(input);
      return _processOutput(output);
    } catch (e) {
      debugPrint('Classification error: $e');
      throw Exception('Classification failed');
    }
  }

  List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    final image = img_lib.decodeImage(imageBytes);
    if (image == null) throw Exception('Image decoding failed');

    final resized = img_lib.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img_lib.Interpolation.cubic,
    );

    return List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            (pixel.r - mean) / std,
            (pixel.g - mean) / std,
            (pixel.b - mean) / std,
          ];
        }),
      ),
    );
  }

  List<List<double>> _runInference(List<List<List<List<double>>>> input) {
    final output = [List<double>.filled(_labels.length, 0.0)];
    _interpreter.run(input, output);
    return output;
  }

  String _processOutput(List<List<double>> output) {
    final probabilities = output[0];
    final maxIndex = probabilities.indexOf(
      probabilities.reduce((a, b) => a > b ? a : b),
    );
    final confidence = (probabilities[maxIndex] * 100).toStringAsFixed(1);
    return '${_labels[maxIndex]} ($confidence%)';
  }

  void dispose() {
    _interpreter.close();
  }
}
