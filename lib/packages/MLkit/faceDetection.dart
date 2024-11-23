import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io'; // Necesario para usar File y mostrar la imagen

class FaceDetectionScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceDetectionScreen({super.key, required this.camera});

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _faceDetector;
  int _numFaces = 0; // Número de rostros detectados
  bool _isProcessing = false; // Estado para mostrar el indicador de carga
  XFile? _imageFile; // Variable para almacenar la imagen tomada

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableLandmarks: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _faceDetector.close();
    super.dispose();
  }

  // Función para tomar la foto y detectar los rostros
  Future<void> _takePicture() async {
    setState(() {
      _isProcessing = true; // Activar el indicador de carga
    });

    try {
      // Tomar la foto
      final XFile file = await _controller.takePicture();

      // Procesar la imagen para detectar los rostros
      final InputImage inputImage = InputImage.fromFilePath(file.path);
      final faces = await _faceDetector.processImage(inputImage);

      // Actualizar el número de rostros detectados
      setState(() {
        _numFaces = faces.length;
        _isProcessing = false; // Desactivar el indicador de carga
        _imageFile = file; // Almacenar la imagen tomada
      });
    } catch (e) {
      setState(() {
        _isProcessing =
            false; // Desactivar el indicador de carga en caso de error
      });
      print("Error al tomar la foto o procesar la imagen: $e");
    }
  }

  // Función para reiniciar la cámara y los estados
  void _resetCamera() {
    setState(() {
      _imageFile = null; // Eliminar la imagen tomada
      _numFaces = 0; // Reiniciar el número de rostros detectados
    });
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconocimiento de Rostros'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Si hay una imagen capturada, mostrarla
                    if (_imageFile != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.file(
                          File(_imageFile!.path),
                          width: double.infinity,
                          height: 500,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      // Vista previa de la cámara
                      SizedBox(
                        width: double.infinity,
                        height: 500, // Restringe el tamaño de la vista previa
                        child: CameraPreview(_controller),
                      ),

                    // Botón para tomar la foto o volver a capturar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : _imageFile != null
                                ? _resetCamera // Volver a capturar si ya se tomó una foto
                                : _takePicture, // Tomar la foto si no hay foto
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              ) // Mostrar un ícono de carga
                            : _imageFile != null
                                ? const Text(
                                    'Volver a Capturar') // Botón para volver a capturar
                                : const Text(
                                    'Detectar Rostros'), // Botón para tomar foto
                      ),
                    ),

                    // Mostrar el número de rostros detectados
                    if (_numFaces > 0)
                      Text(
                        'Rostros detectados: $_numFaces',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    else if (_imageFile != null)
                      const Text(
                        'No se detectaron rostros.',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
