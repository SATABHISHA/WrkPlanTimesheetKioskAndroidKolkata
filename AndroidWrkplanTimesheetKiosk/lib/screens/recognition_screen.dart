import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({Key? key}) : super(key: key);

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  String _selectedTask = 'Task1';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _captureImage() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final image = await _cameraController!.takePicture();
        setState(() {
          _capturedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
  }

  void _submitAttendance() {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture an image')),
      );
      return;
    }

    // TODO: Send image and data to server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance recorded successfully')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facial Recognition'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isCameraInitialized && _capturedImage == null)
                Container(
                  height: 400,
                  color: Colors.black,
                  child: CameraPreview(_cameraController!),
                )
              else if (_capturedImage != null)
                Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Image.file(File(_capturedImage!.path)),
                )
              else
                Container(
                  height: 400,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('Camera not available'),
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedTask,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Task1',
                          child: Text('Task 1'),
                        ),
                        DropdownMenuItem(
                          value: 'Task2',
                          child: Text('Task 2'),
                        ),
                        DropdownMenuItem(
                          value: 'Task3',
                          child: Text('Task 3'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTask = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _captureImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Capture'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _capturedImage != null ? () {
                              setState(() {
                                _capturedImage = null;
                              });
                            } : null,
                            child: const Text('Retake'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitAttendance,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Submit Attendance'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
