import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Fixed super parameter

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TFLiteService _tfliteService = TFLiteService();
  Uint8List? _imageBytes;
  String _resultLabel = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      await _tfliteService.initialize();
    } catch (e) {
      _showError('Model initialization failed: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final result = await _tfliteService.classifyImage(bytes);

      setState(() {
        _imageBytes = bytes;
        _resultLabel = result;
      });
    } catch (e) {
      _showError('Image processing error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ), // Fixed missing parenthesis
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTakes - Food Classifier'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildImagePreview()),
            const SizedBox(height: 20),
            _buildResultSection(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          _imageBytes != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
              )
              : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('No image selected'),
                  ],
                ),
              ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        if (_isLoading) const CircularProgressIndicator(),
        if (_resultLabel.isNotEmpty)
          Text(
            'Predicted Food:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (_resultLabel.isNotEmpty)
          Text(
            _resultLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildImageButton(
          icon: Icons.camera_alt,
          label: 'Camera',
          source: ImageSource.camera,
        ),
        _buildImageButton(
          icon: Icons.photo_library,
          label: 'Gallery',
          source: ImageSource.gallery,
        ),
      ],
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label),
      onPressed: () => _pickImage(source),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}
