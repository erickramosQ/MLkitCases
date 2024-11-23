import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class DetectObjectScreen extends StatefulWidget {
  const DetectObjectScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DetectObjectScreenState createState() => _DetectObjectScreenState();
}

class _DetectObjectScreenState extends State<DetectObjectScreen> {
  File? _image;
  List<String> _detectedObjects = [];

  final Map<String, String> etiquetasEnEspanol = {
    'Person': 'Persona',
    'Car': 'Coche',
    'Dog': 'Perro',
    'Cat': 'Gato',
    'Chair': 'Silla',
    'Table': 'Mesa',
    'Laptop': 'Portátil',
    'Bottle': 'Botella',
    'Fashion good': 'Ropa o accesorio',
    'Home good': 'Artículo para el hogar',
    'House': 'Casa',
    'Good': 'Objeto',
    'Food': 'Comida',
    'Furniture': 'Mueble',
    // Puedes añadir más traducciones aquí si encuentras etiquetas adicionales
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detectedObjects = [];
      });
      await detectObjects(File(pickedFile.path));
    }
  }

  Future<void> detectObjects(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single, // Para imágenes estáticas
      classifyObjects: true,
      multipleObjects: true,
    );
    final objectDetector = ObjectDetector(options: options);

    try {
      final objects = await objectDetector.processImage(inputImage);

      if (objects.isEmpty) {
        setState(() {
          _detectedObjects = ["No se detectaron objetos en la imagen."];
        });
      } else {
        _setDetectedObjects(objects);
      }
    } catch (e) {
      setState(() {
        _detectedObjects = ["Error al detectar objetos: $e"];
      });
    } finally {
      objectDetector.close();
    }
  }

  void _setDetectedObjects(List<DetectedObject> objects) {
    setState(() {
      _detectedObjects = objects.expand((obj) {
        return obj.labels.map((label) {
          final etiqueta = etiquetasEnEspanol[label.text] ?? label.text;
          final confianza = (label.confidence * 100).toStringAsFixed(1);
          return "$etiqueta ($confianza%)";
        }).toList();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detección de Objetos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // Mostrar imagen o marco con marcador de posición
              if (_image != null)
                Image.file(
                  _image!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.fill,
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Color del marco
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image,
                            size: 50, color: Colors.grey), // Ícono
                        SizedBox(height: 8),
                        Text(
                          "No hay imagen seleccionada",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Elegir foto'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _detectedObjects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(
                        _detectedObjects[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
