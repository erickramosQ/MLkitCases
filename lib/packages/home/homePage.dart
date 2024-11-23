import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit'),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            'assets/images/dev.png',
            width: 300, // Tamaño opcional
            height: 200, // Tamaño opcional
            fit: BoxFit.contain, // Ajuste de la imagen
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading:
                const Icon(Icons.document_scanner_sharp, color: Colors.blue),
            title: const Text('Reconocimiento de Placas'),
            onTap: () {
              Navigator.pushNamed(context, '/page1');
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_objects, color: Colors.blue),
            title: const Text('Reconocimiento de objetos'),
            onTap: () {
              Navigator.pushNamed(context, '/page2');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Reconocimiento de Rostros'),
            onTap: () {
              Navigator.pushNamed(context, '/page3');
            },
          ),
        ],
      ),
    );
  }
}
