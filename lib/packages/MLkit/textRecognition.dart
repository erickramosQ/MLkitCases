import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  File? _image;
  String _recognizedText = "";

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _recognizePlate(File(pickedFile.path));
    }
  }

  Future<void> _recognizePlate(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textDetector = GoogleMlKit.vision.textRecognizer();

      // Procesa la imagen
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);
      await textDetector.close(); // Cierra el detector después de usarlo.

      // Expresión regular para el formato de placas bolivianas (ejemplo: 1633KIU)
      final placaRegex = RegExp(r'\b\d{4}[A-Z]{3}\b');

      // Busca la placa en el texto reconocido
      String? placaEncontrada;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final match = placaRegex.firstMatch(line.text);
          if (match != null) {
            placaEncontrada =
                match.group(0); // Obtén el primer valor que coincida.
            break; // Detenemos la búsqueda al encontrar la placa.
          }
        }
        if (placaEncontrada != null) {
          break; // Salimos del bucle si ya encontramos la placa.
        }
      }

      // Actualiza el estado con la placa encontrada o un mensaje de error.
      setState(() {
        _recognizedText = placaEncontrada ?? "No se encontró ninguna placa.";
      });
    } catch (e) {
      setState(() {
        _recognizedText = "Error al reconocer la placa: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit Text Recognition'),
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
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.fill,
                )
              else
                Container(
                  height: 200,
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
                child: Column(
                  children: [
                    const Text(
                      'Placa encontrada:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _recognizedText,
                      style: const TextStyle(fontSize: 25),
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
