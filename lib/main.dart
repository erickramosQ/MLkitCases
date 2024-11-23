import 'package:devfest_artificial_vision/packages/MLkit/faceDetection.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Importa el paquete camera
import 'packages/MLkit/detectObjects.dart';
import 'packages/MLkit/textRecognition.dart';
import 'packages/home/homePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obteniendo las cámaras disponibles
  final cameras = await availableCameras();
  final firstCamera = cameras.first; // Aquí seleccionamos la primera cámara

  runApp(MyApp(camera: firstCamera)); // Pasa la cámara al MyApp
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  // Asegúrate de recibir la cámara en el constructor
  const MyApp({
    super.key,
    required this.camera,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ML Kit Demo',
      home: const HomePage(),
      routes: {
        '/page1': (context) => const TextRecognitionScreen(),
        '/page2': (context) => const DetectObjectScreen(),
        // Pasa la cámara a FaceDetectionScreen
        '/page3': (context) => FaceDetectionScreen(camera: camera),
      },
    );
  }
}
